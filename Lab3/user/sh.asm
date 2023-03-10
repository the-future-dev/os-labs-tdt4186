
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
    }
    exit(0);
}

int getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
    write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	3de58593          	addi	a1,a1,990 # 13f0 <malloc+0xee>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	eac080e7          	jalr	-340(ra) # ec8 <write>
    memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	c84080e7          	jalr	-892(ra) # cae <memset>
    gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	cbe080e7          	jalr	-834(ra) # cf4 <gets>
    if (buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
        return -1;
    return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
    }
    exit(0);
}

void panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
    fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	39858593          	addi	a1,a1,920 # 13f8 <malloc+0xf6>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	1b2080e7          	jalr	434(ra) # 121c <fprintf>
    exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	e34080e7          	jalr	-460(ra) # ea8 <exit>

000000000000007c <fork1>:
}

int fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
    int pid;

    pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	e1c080e7          	jalr	-484(ra) # ea0 <fork>
    if (pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
        panic("fork");
    return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
        panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	36650513          	addi	a0,a0,870 # 1400 <malloc+0xfe>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	ec26                	sd	s1,24(sp)
      b2:	1800                	addi	s0,sp,48
    if (cmd == 0)
      b4:	c10d                	beqz	a0,d6 <runcmd+0x2c>
      b6:	84aa                	mv	s1,a0
    switch (cmd->type)
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e263          	bltu	a5,a4,e0 <runcmd+0x36>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	44e70713          	addi	a4,a4,1102 # 1514 <malloc+0x212>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
        exit(1);
      d6:	4505                	li	a0,1
      d8:	00001097          	auipc	ra,0x1
      dc:	dd0080e7          	jalr	-560(ra) # ea8 <exit>
        panic("runcmd");
      e0:	00001517          	auipc	a0,0x1
      e4:	32850513          	addi	a0,a0,808 # 1408 <malloc+0x106>
      e8:	00000097          	auipc	ra,0x0
      ec:	f6e080e7          	jalr	-146(ra) # 56 <panic>
        if (ecmd->argv[0] == 0)
      f0:	6508                	ld	a0,8(a0)
      f2:	c515                	beqz	a0,11e <runcmd+0x74>
        exec(ecmd->argv[0], ecmd->argv);
      f4:	00848593          	addi	a1,s1,8
      f8:	00001097          	auipc	ra,0x1
      fc:	de8080e7          	jalr	-536(ra) # ee0 <exec>
        fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     100:	6490                	ld	a2,8(s1)
     102:	00001597          	auipc	a1,0x1
     106:	30e58593          	addi	a1,a1,782 # 1410 <malloc+0x10e>
     10a:	4509                	li	a0,2
     10c:	00001097          	auipc	ra,0x1
     110:	110080e7          	jalr	272(ra) # 121c <fprintf>
    exit(0);
     114:	4501                	li	a0,0
     116:	00001097          	auipc	ra,0x1
     11a:	d92080e7          	jalr	-622(ra) # ea8 <exit>
            exit(1);
     11e:	4505                	li	a0,1
     120:	00001097          	auipc	ra,0x1
     124:	d88080e7          	jalr	-632(ra) # ea8 <exit>
        close(rcmd->fd);
     128:	5148                	lw	a0,36(a0)
     12a:	00001097          	auipc	ra,0x1
     12e:	da6080e7          	jalr	-602(ra) # ed0 <close>
        if (open(rcmd->file, rcmd->mode) < 0)
     132:	508c                	lw	a1,32(s1)
     134:	6888                	ld	a0,16(s1)
     136:	00001097          	auipc	ra,0x1
     13a:	db2080e7          	jalr	-590(ra) # ee8 <open>
     13e:	00054763          	bltz	a0,14c <runcmd+0xa2>
        runcmd(rcmd->cmd);
     142:	6488                	ld	a0,8(s1)
     144:	00000097          	auipc	ra,0x0
     148:	f66080e7          	jalr	-154(ra) # aa <runcmd>
            fprintf(2, "open %s failed\n", rcmd->file);
     14c:	6890                	ld	a2,16(s1)
     14e:	00001597          	auipc	a1,0x1
     152:	2d258593          	addi	a1,a1,722 # 1420 <malloc+0x11e>
     156:	4509                	li	a0,2
     158:	00001097          	auipc	ra,0x1
     15c:	0c4080e7          	jalr	196(ra) # 121c <fprintf>
            exit(1);
     160:	4505                	li	a0,1
     162:	00001097          	auipc	ra,0x1
     166:	d46080e7          	jalr	-698(ra) # ea8 <exit>
        if (fork1() == 0)
     16a:	00000097          	auipc	ra,0x0
     16e:	f12080e7          	jalr	-238(ra) # 7c <fork1>
     172:	e511                	bnez	a0,17e <runcmd+0xd4>
            runcmd(lcmd->left);
     174:	6488                	ld	a0,8(s1)
     176:	00000097          	auipc	ra,0x0
     17a:	f34080e7          	jalr	-204(ra) # aa <runcmd>
        wait(0);
     17e:	4501                	li	a0,0
     180:	00001097          	auipc	ra,0x1
     184:	d30080e7          	jalr	-720(ra) # eb0 <wait>
        runcmd(lcmd->right);
     188:	6888                	ld	a0,16(s1)
     18a:	00000097          	auipc	ra,0x0
     18e:	f20080e7          	jalr	-224(ra) # aa <runcmd>
        if (pipe(p) < 0)
     192:	fd840513          	addi	a0,s0,-40
     196:	00001097          	auipc	ra,0x1
     19a:	d22080e7          	jalr	-734(ra) # eb8 <pipe>
     19e:	04054363          	bltz	a0,1e4 <runcmd+0x13a>
        if (fork1() == 0)
     1a2:	00000097          	auipc	ra,0x0
     1a6:	eda080e7          	jalr	-294(ra) # 7c <fork1>
     1aa:	e529                	bnez	a0,1f4 <runcmd+0x14a>
            close(1);
     1ac:	4505                	li	a0,1
     1ae:	00001097          	auipc	ra,0x1
     1b2:	d22080e7          	jalr	-734(ra) # ed0 <close>
            dup(p[1]);
     1b6:	fdc42503          	lw	a0,-36(s0)
     1ba:	00001097          	auipc	ra,0x1
     1be:	d66080e7          	jalr	-666(ra) # f20 <dup>
            close(p[0]);
     1c2:	fd842503          	lw	a0,-40(s0)
     1c6:	00001097          	auipc	ra,0x1
     1ca:	d0a080e7          	jalr	-758(ra) # ed0 <close>
            close(p[1]);
     1ce:	fdc42503          	lw	a0,-36(s0)
     1d2:	00001097          	auipc	ra,0x1
     1d6:	cfe080e7          	jalr	-770(ra) # ed0 <close>
            runcmd(pcmd->left);
     1da:	6488                	ld	a0,8(s1)
     1dc:	00000097          	auipc	ra,0x0
     1e0:	ece080e7          	jalr	-306(ra) # aa <runcmd>
            panic("pipe");
     1e4:	00001517          	auipc	a0,0x1
     1e8:	24c50513          	addi	a0,a0,588 # 1430 <malloc+0x12e>
     1ec:	00000097          	auipc	ra,0x0
     1f0:	e6a080e7          	jalr	-406(ra) # 56 <panic>
        if (fork1() == 0)
     1f4:	00000097          	auipc	ra,0x0
     1f8:	e88080e7          	jalr	-376(ra) # 7c <fork1>
     1fc:	ed05                	bnez	a0,234 <runcmd+0x18a>
            close(0);
     1fe:	00001097          	auipc	ra,0x1
     202:	cd2080e7          	jalr	-814(ra) # ed0 <close>
            dup(p[0]);
     206:	fd842503          	lw	a0,-40(s0)
     20a:	00001097          	auipc	ra,0x1
     20e:	d16080e7          	jalr	-746(ra) # f20 <dup>
            close(p[0]);
     212:	fd842503          	lw	a0,-40(s0)
     216:	00001097          	auipc	ra,0x1
     21a:	cba080e7          	jalr	-838(ra) # ed0 <close>
            close(p[1]);
     21e:	fdc42503          	lw	a0,-36(s0)
     222:	00001097          	auipc	ra,0x1
     226:	cae080e7          	jalr	-850(ra) # ed0 <close>
            runcmd(pcmd->right);
     22a:	6888                	ld	a0,16(s1)
     22c:	00000097          	auipc	ra,0x0
     230:	e7e080e7          	jalr	-386(ra) # aa <runcmd>
        close(p[0]);
     234:	fd842503          	lw	a0,-40(s0)
     238:	00001097          	auipc	ra,0x1
     23c:	c98080e7          	jalr	-872(ra) # ed0 <close>
        close(p[1]);
     240:	fdc42503          	lw	a0,-36(s0)
     244:	00001097          	auipc	ra,0x1
     248:	c8c080e7          	jalr	-884(ra) # ed0 <close>
        wait(0);
     24c:	4501                	li	a0,0
     24e:	00001097          	auipc	ra,0x1
     252:	c62080e7          	jalr	-926(ra) # eb0 <wait>
        wait(0);
     256:	4501                	li	a0,0
     258:	00001097          	auipc	ra,0x1
     25c:	c58080e7          	jalr	-936(ra) # eb0 <wait>
        break;
     260:	bd55                	j	114 <runcmd+0x6a>
        if (fork1() == 0)
     262:	00000097          	auipc	ra,0x0
     266:	e1a080e7          	jalr	-486(ra) # 7c <fork1>
     26a:	ea0515e3          	bnez	a0,114 <runcmd+0x6a>
            runcmd(bcmd->cmd);
     26e:	6488                	ld	a0,8(s1)
     270:	00000097          	auipc	ra,0x0
     274:	e3a080e7          	jalr	-454(ra) # aa <runcmd>

0000000000000278 <execcmd>:
// PAGEBREAK!
//  Constructors

struct cmd *
execcmd(void)
{
     278:	1101                	addi	sp,sp,-32
     27a:	ec06                	sd	ra,24(sp)
     27c:	e822                	sd	s0,16(sp)
     27e:	e426                	sd	s1,8(sp)
     280:	1000                	addi	s0,sp,32
    struct execcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     282:	0a800513          	li	a0,168
     286:	00001097          	auipc	ra,0x1
     28a:	07c080e7          	jalr	124(ra) # 1302 <malloc>
     28e:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     290:	0a800613          	li	a2,168
     294:	4581                	li	a1,0
     296:	00001097          	auipc	ra,0x1
     29a:	a18080e7          	jalr	-1512(ra) # cae <memset>
    cmd->type = EXEC;
     29e:	4785                	li	a5,1
     2a0:	c09c                	sw	a5,0(s1)
    return (struct cmd *)cmd;
}
     2a2:	8526                	mv	a0,s1
     2a4:	60e2                	ld	ra,24(sp)
     2a6:	6442                	ld	s0,16(sp)
     2a8:	64a2                	ld	s1,8(sp)
     2aa:	6105                	addi	sp,sp,32
     2ac:	8082                	ret

00000000000002ae <redircmd>:

struct cmd *
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2ae:	7139                	addi	sp,sp,-64
     2b0:	fc06                	sd	ra,56(sp)
     2b2:	f822                	sd	s0,48(sp)
     2b4:	f426                	sd	s1,40(sp)
     2b6:	f04a                	sd	s2,32(sp)
     2b8:	ec4e                	sd	s3,24(sp)
     2ba:	e852                	sd	s4,16(sp)
     2bc:	e456                	sd	s5,8(sp)
     2be:	e05a                	sd	s6,0(sp)
     2c0:	0080                	addi	s0,sp,64
     2c2:	8b2a                	mv	s6,a0
     2c4:	8aae                	mv	s5,a1
     2c6:	8a32                	mv	s4,a2
     2c8:	89b6                	mv	s3,a3
     2ca:	893a                	mv	s2,a4
    struct redircmd *cmd;

    cmd = malloc(sizeof(*cmd));
     2cc:	02800513          	li	a0,40
     2d0:	00001097          	auipc	ra,0x1
     2d4:	032080e7          	jalr	50(ra) # 1302 <malloc>
     2d8:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     2da:	02800613          	li	a2,40
     2de:	4581                	li	a1,0
     2e0:	00001097          	auipc	ra,0x1
     2e4:	9ce080e7          	jalr	-1586(ra) # cae <memset>
    cmd->type = REDIR;
     2e8:	4789                	li	a5,2
     2ea:	c09c                	sw	a5,0(s1)
    cmd->cmd = subcmd;
     2ec:	0164b423          	sd	s6,8(s1)
    cmd->file = file;
     2f0:	0154b823          	sd	s5,16(s1)
    cmd->efile = efile;
     2f4:	0144bc23          	sd	s4,24(s1)
    cmd->mode = mode;
     2f8:	0334a023          	sw	s3,32(s1)
    cmd->fd = fd;
     2fc:	0324a223          	sw	s2,36(s1)
    return (struct cmd *)cmd;
}
     300:	8526                	mv	a0,s1
     302:	70e2                	ld	ra,56(sp)
     304:	7442                	ld	s0,48(sp)
     306:	74a2                	ld	s1,40(sp)
     308:	7902                	ld	s2,32(sp)
     30a:	69e2                	ld	s3,24(sp)
     30c:	6a42                	ld	s4,16(sp)
     30e:	6aa2                	ld	s5,8(sp)
     310:	6b02                	ld	s6,0(sp)
     312:	6121                	addi	sp,sp,64
     314:	8082                	ret

0000000000000316 <pipecmd>:

struct cmd *
pipecmd(struct cmd *left, struct cmd *right)
{
     316:	7179                	addi	sp,sp,-48
     318:	f406                	sd	ra,40(sp)
     31a:	f022                	sd	s0,32(sp)
     31c:	ec26                	sd	s1,24(sp)
     31e:	e84a                	sd	s2,16(sp)
     320:	e44e                	sd	s3,8(sp)
     322:	1800                	addi	s0,sp,48
     324:	89aa                	mv	s3,a0
     326:	892e                	mv	s2,a1
    struct pipecmd *cmd;

    cmd = malloc(sizeof(*cmd));
     328:	4561                	li	a0,24
     32a:	00001097          	auipc	ra,0x1
     32e:	fd8080e7          	jalr	-40(ra) # 1302 <malloc>
     332:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     334:	4661                	li	a2,24
     336:	4581                	li	a1,0
     338:	00001097          	auipc	ra,0x1
     33c:	976080e7          	jalr	-1674(ra) # cae <memset>
    cmd->type = PIPE;
     340:	478d                	li	a5,3
     342:	c09c                	sw	a5,0(s1)
    cmd->left = left;
     344:	0134b423          	sd	s3,8(s1)
    cmd->right = right;
     348:	0124b823          	sd	s2,16(s1)
    return (struct cmd *)cmd;
}
     34c:	8526                	mv	a0,s1
     34e:	70a2                	ld	ra,40(sp)
     350:	7402                	ld	s0,32(sp)
     352:	64e2                	ld	s1,24(sp)
     354:	6942                	ld	s2,16(sp)
     356:	69a2                	ld	s3,8(sp)
     358:	6145                	addi	sp,sp,48
     35a:	8082                	ret

000000000000035c <listcmd>:

struct cmd *
listcmd(struct cmd *left, struct cmd *right)
{
     35c:	7179                	addi	sp,sp,-48
     35e:	f406                	sd	ra,40(sp)
     360:	f022                	sd	s0,32(sp)
     362:	ec26                	sd	s1,24(sp)
     364:	e84a                	sd	s2,16(sp)
     366:	e44e                	sd	s3,8(sp)
     368:	1800                	addi	s0,sp,48
     36a:	89aa                	mv	s3,a0
     36c:	892e                	mv	s2,a1
    struct listcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     36e:	4561                	li	a0,24
     370:	00001097          	auipc	ra,0x1
     374:	f92080e7          	jalr	-110(ra) # 1302 <malloc>
     378:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     37a:	4661                	li	a2,24
     37c:	4581                	li	a1,0
     37e:	00001097          	auipc	ra,0x1
     382:	930080e7          	jalr	-1744(ra) # cae <memset>
    cmd->type = LIST;
     386:	4791                	li	a5,4
     388:	c09c                	sw	a5,0(s1)
    cmd->left = left;
     38a:	0134b423          	sd	s3,8(s1)
    cmd->right = right;
     38e:	0124b823          	sd	s2,16(s1)
    return (struct cmd *)cmd;
}
     392:	8526                	mv	a0,s1
     394:	70a2                	ld	ra,40(sp)
     396:	7402                	ld	s0,32(sp)
     398:	64e2                	ld	s1,24(sp)
     39a:	6942                	ld	s2,16(sp)
     39c:	69a2                	ld	s3,8(sp)
     39e:	6145                	addi	sp,sp,48
     3a0:	8082                	ret

00000000000003a2 <backcmd>:

struct cmd *
backcmd(struct cmd *subcmd)
{
     3a2:	1101                	addi	sp,sp,-32
     3a4:	ec06                	sd	ra,24(sp)
     3a6:	e822                	sd	s0,16(sp)
     3a8:	e426                	sd	s1,8(sp)
     3aa:	e04a                	sd	s2,0(sp)
     3ac:	1000                	addi	s0,sp,32
     3ae:	892a                	mv	s2,a0
    struct backcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     3b0:	4541                	li	a0,16
     3b2:	00001097          	auipc	ra,0x1
     3b6:	f50080e7          	jalr	-176(ra) # 1302 <malloc>
     3ba:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     3bc:	4641                	li	a2,16
     3be:	4581                	li	a1,0
     3c0:	00001097          	auipc	ra,0x1
     3c4:	8ee080e7          	jalr	-1810(ra) # cae <memset>
    cmd->type = BACK;
     3c8:	4795                	li	a5,5
     3ca:	c09c                	sw	a5,0(s1)
    cmd->cmd = subcmd;
     3cc:	0124b423          	sd	s2,8(s1)
    return (struct cmd *)cmd;
}
     3d0:	8526                	mv	a0,s1
     3d2:	60e2                	ld	ra,24(sp)
     3d4:	6442                	ld	s0,16(sp)
     3d6:	64a2                	ld	s1,8(sp)
     3d8:	6902                	ld	s2,0(sp)
     3da:	6105                	addi	sp,sp,32
     3dc:	8082                	ret

00000000000003de <gettoken>:

char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int gettoken(char **ps, char *es, char **q, char **eq)
{
     3de:	7139                	addi	sp,sp,-64
     3e0:	fc06                	sd	ra,56(sp)
     3e2:	f822                	sd	s0,48(sp)
     3e4:	f426                	sd	s1,40(sp)
     3e6:	f04a                	sd	s2,32(sp)
     3e8:	ec4e                	sd	s3,24(sp)
     3ea:	e852                	sd	s4,16(sp)
     3ec:	e456                	sd	s5,8(sp)
     3ee:	e05a                	sd	s6,0(sp)
     3f0:	0080                	addi	s0,sp,64
     3f2:	8a2a                	mv	s4,a0
     3f4:	892e                	mv	s2,a1
     3f6:	8ab2                	mv	s5,a2
     3f8:	8b36                	mv	s6,a3
    char *s;
    int ret;

    s = *ps;
     3fa:	6104                	ld	s1,0(a0)
    while (s < es && strchr(whitespace, *s))
     3fc:	00002997          	auipc	s3,0x2
     400:	c0c98993          	addi	s3,s3,-1012 # 2008 <whitespace>
     404:	00b4fe63          	bgeu	s1,a1,420 <gettoken+0x42>
     408:	0004c583          	lbu	a1,0(s1)
     40c:	854e                	mv	a0,s3
     40e:	00001097          	auipc	ra,0x1
     412:	8c2080e7          	jalr	-1854(ra) # cd0 <strchr>
     416:	c509                	beqz	a0,420 <gettoken+0x42>
        s++;
     418:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     41a:	fe9917e3          	bne	s2,s1,408 <gettoken+0x2a>
        s++;
     41e:	84ca                	mv	s1,s2
    if (q)
     420:	000a8463          	beqz	s5,428 <gettoken+0x4a>
        *q = s;
     424:	009ab023          	sd	s1,0(s5)
    ret = *s;
     428:	0004c783          	lbu	a5,0(s1)
     42c:	00078a9b          	sext.w	s5,a5
    switch (*s)
     430:	03c00713          	li	a4,60
     434:	06f76663          	bltu	a4,a5,4a0 <gettoken+0xc2>
     438:	03a00713          	li	a4,58
     43c:	00f76e63          	bltu	a4,a5,458 <gettoken+0x7a>
     440:	cf89                	beqz	a5,45a <gettoken+0x7c>
     442:	02600713          	li	a4,38
     446:	00e78963          	beq	a5,a4,458 <gettoken+0x7a>
     44a:	fd87879b          	addiw	a5,a5,-40
     44e:	0ff7f793          	zext.b	a5,a5
     452:	4705                	li	a4,1
     454:	06f76d63          	bltu	a4,a5,4ce <gettoken+0xf0>
    case '(':
    case ')':
    case ';':
    case '&':
    case '<':
        s++;
     458:	0485                	addi	s1,s1,1
        ret = 'a';
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
            s++;
        break;
    }
    if (eq)
     45a:	000b0463          	beqz	s6,462 <gettoken+0x84>
        *eq = s;
     45e:	009b3023          	sd	s1,0(s6)

    while (s < es && strchr(whitespace, *s))
     462:	00002997          	auipc	s3,0x2
     466:	ba698993          	addi	s3,s3,-1114 # 2008 <whitespace>
     46a:	0124fe63          	bgeu	s1,s2,486 <gettoken+0xa8>
     46e:	0004c583          	lbu	a1,0(s1)
     472:	854e                	mv	a0,s3
     474:	00001097          	auipc	ra,0x1
     478:	85c080e7          	jalr	-1956(ra) # cd0 <strchr>
     47c:	c509                	beqz	a0,486 <gettoken+0xa8>
        s++;
     47e:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     480:	fe9917e3          	bne	s2,s1,46e <gettoken+0x90>
        s++;
     484:	84ca                	mv	s1,s2
    *ps = s;
     486:	009a3023          	sd	s1,0(s4)
    return ret;
}
     48a:	8556                	mv	a0,s5
     48c:	70e2                	ld	ra,56(sp)
     48e:	7442                	ld	s0,48(sp)
     490:	74a2                	ld	s1,40(sp)
     492:	7902                	ld	s2,32(sp)
     494:	69e2                	ld	s3,24(sp)
     496:	6a42                	ld	s4,16(sp)
     498:	6aa2                	ld	s5,8(sp)
     49a:	6b02                	ld	s6,0(sp)
     49c:	6121                	addi	sp,sp,64
     49e:	8082                	ret
    switch (*s)
     4a0:	03e00713          	li	a4,62
     4a4:	02e79163          	bne	a5,a4,4c6 <gettoken+0xe8>
        s++;
     4a8:	00148693          	addi	a3,s1,1
        if (*s == '>')
     4ac:	0014c703          	lbu	a4,1(s1)
     4b0:	03e00793          	li	a5,62
            s++;
     4b4:	0489                	addi	s1,s1,2
            ret = '+';
     4b6:	02b00a93          	li	s5,43
        if (*s == '>')
     4ba:	faf700e3          	beq	a4,a5,45a <gettoken+0x7c>
        s++;
     4be:	84b6                	mv	s1,a3
    ret = *s;
     4c0:	03e00a93          	li	s5,62
     4c4:	bf59                	j	45a <gettoken+0x7c>
    switch (*s)
     4c6:	07c00713          	li	a4,124
     4ca:	f8e787e3          	beq	a5,a4,458 <gettoken+0x7a>
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4ce:	00002997          	auipc	s3,0x2
     4d2:	b3a98993          	addi	s3,s3,-1222 # 2008 <whitespace>
     4d6:	00002a97          	auipc	s5,0x2
     4da:	b2aa8a93          	addi	s5,s5,-1238 # 2000 <symbols>
     4de:	0324f663          	bgeu	s1,s2,50a <gettoken+0x12c>
     4e2:	0004c583          	lbu	a1,0(s1)
     4e6:	854e                	mv	a0,s3
     4e8:	00000097          	auipc	ra,0x0
     4ec:	7e8080e7          	jalr	2024(ra) # cd0 <strchr>
     4f0:	e50d                	bnez	a0,51a <gettoken+0x13c>
     4f2:	0004c583          	lbu	a1,0(s1)
     4f6:	8556                	mv	a0,s5
     4f8:	00000097          	auipc	ra,0x0
     4fc:	7d8080e7          	jalr	2008(ra) # cd0 <strchr>
     500:	e911                	bnez	a0,514 <gettoken+0x136>
            s++;
     502:	0485                	addi	s1,s1,1
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     504:	fc991fe3          	bne	s2,s1,4e2 <gettoken+0x104>
            s++;
     508:	84ca                	mv	s1,s2
    if (eq)
     50a:	06100a93          	li	s5,97
     50e:	f40b18e3          	bnez	s6,45e <gettoken+0x80>
     512:	bf95                	j	486 <gettoken+0xa8>
        ret = 'a';
     514:	06100a93          	li	s5,97
     518:	b789                	j	45a <gettoken+0x7c>
     51a:	06100a93          	li	s5,97
     51e:	bf35                	j	45a <gettoken+0x7c>

0000000000000520 <peek>:

int peek(char **ps, char *es, char *toks)
{
     520:	7139                	addi	sp,sp,-64
     522:	fc06                	sd	ra,56(sp)
     524:	f822                	sd	s0,48(sp)
     526:	f426                	sd	s1,40(sp)
     528:	f04a                	sd	s2,32(sp)
     52a:	ec4e                	sd	s3,24(sp)
     52c:	e852                	sd	s4,16(sp)
     52e:	e456                	sd	s5,8(sp)
     530:	0080                	addi	s0,sp,64
     532:	8a2a                	mv	s4,a0
     534:	892e                	mv	s2,a1
     536:	8ab2                	mv	s5,a2
    char *s;

    s = *ps;
     538:	6104                	ld	s1,0(a0)
    while (s < es && strchr(whitespace, *s))
     53a:	00002997          	auipc	s3,0x2
     53e:	ace98993          	addi	s3,s3,-1330 # 2008 <whitespace>
     542:	00b4fe63          	bgeu	s1,a1,55e <peek+0x3e>
     546:	0004c583          	lbu	a1,0(s1)
     54a:	854e                	mv	a0,s3
     54c:	00000097          	auipc	ra,0x0
     550:	784080e7          	jalr	1924(ra) # cd0 <strchr>
     554:	c509                	beqz	a0,55e <peek+0x3e>
        s++;
     556:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     558:	fe9917e3          	bne	s2,s1,546 <peek+0x26>
        s++;
     55c:	84ca                	mv	s1,s2
    *ps = s;
     55e:	009a3023          	sd	s1,0(s4)
    return *s && strchr(toks, *s);
     562:	0004c583          	lbu	a1,0(s1)
     566:	4501                	li	a0,0
     568:	e991                	bnez	a1,57c <peek+0x5c>
}
     56a:	70e2                	ld	ra,56(sp)
     56c:	7442                	ld	s0,48(sp)
     56e:	74a2                	ld	s1,40(sp)
     570:	7902                	ld	s2,32(sp)
     572:	69e2                	ld	s3,24(sp)
     574:	6a42                	ld	s4,16(sp)
     576:	6aa2                	ld	s5,8(sp)
     578:	6121                	addi	sp,sp,64
     57a:	8082                	ret
    return *s && strchr(toks, *s);
     57c:	8556                	mv	a0,s5
     57e:	00000097          	auipc	ra,0x0
     582:	752080e7          	jalr	1874(ra) # cd0 <strchr>
     586:	00a03533          	snez	a0,a0
     58a:	b7c5                	j	56a <peek+0x4a>

000000000000058c <parseredirs>:
    return cmd;
}

struct cmd *
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     58c:	7159                	addi	sp,sp,-112
     58e:	f486                	sd	ra,104(sp)
     590:	f0a2                	sd	s0,96(sp)
     592:	eca6                	sd	s1,88(sp)
     594:	e8ca                	sd	s2,80(sp)
     596:	e4ce                	sd	s3,72(sp)
     598:	e0d2                	sd	s4,64(sp)
     59a:	fc56                	sd	s5,56(sp)
     59c:	f85a                	sd	s6,48(sp)
     59e:	f45e                	sd	s7,40(sp)
     5a0:	f062                	sd	s8,32(sp)
     5a2:	ec66                	sd	s9,24(sp)
     5a4:	1880                	addi	s0,sp,112
     5a6:	8a2a                	mv	s4,a0
     5a8:	89ae                	mv	s3,a1
     5aa:	8932                	mv	s2,a2
    int tok;
    char *q, *eq;

    while (peek(ps, es, "<>"))
     5ac:	00001b97          	auipc	s7,0x1
     5b0:	eacb8b93          	addi	s7,s7,-340 # 1458 <malloc+0x156>
    {
        tok = gettoken(ps, es, 0, 0);
        if (gettoken(ps, es, &q, &eq) != 'a')
     5b4:	06100c13          	li	s8,97
            panic("missing file for redirection");
        switch (tok)
     5b8:	03c00c93          	li	s9,60
    while (peek(ps, es, "<>"))
     5bc:	a02d                	j	5e6 <parseredirs+0x5a>
            panic("missing file for redirection");
     5be:	00001517          	auipc	a0,0x1
     5c2:	e7a50513          	addi	a0,a0,-390 # 1438 <malloc+0x136>
     5c6:	00000097          	auipc	ra,0x0
     5ca:	a90080e7          	jalr	-1392(ra) # 56 <panic>
        {
        case '<':
            cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5ce:	4701                	li	a4,0
     5d0:	4681                	li	a3,0
     5d2:	f9043603          	ld	a2,-112(s0)
     5d6:	f9843583          	ld	a1,-104(s0)
     5da:	8552                	mv	a0,s4
     5dc:	00000097          	auipc	ra,0x0
     5e0:	cd2080e7          	jalr	-814(ra) # 2ae <redircmd>
     5e4:	8a2a                	mv	s4,a0
        switch (tok)
     5e6:	03e00b13          	li	s6,62
     5ea:	02b00a93          	li	s5,43
    while (peek(ps, es, "<>"))
     5ee:	865e                	mv	a2,s7
     5f0:	85ca                	mv	a1,s2
     5f2:	854e                	mv	a0,s3
     5f4:	00000097          	auipc	ra,0x0
     5f8:	f2c080e7          	jalr	-212(ra) # 520 <peek>
     5fc:	c925                	beqz	a0,66c <parseredirs+0xe0>
        tok = gettoken(ps, es, 0, 0);
     5fe:	4681                	li	a3,0
     600:	4601                	li	a2,0
     602:	85ca                	mv	a1,s2
     604:	854e                	mv	a0,s3
     606:	00000097          	auipc	ra,0x0
     60a:	dd8080e7          	jalr	-552(ra) # 3de <gettoken>
     60e:	84aa                	mv	s1,a0
        if (gettoken(ps, es, &q, &eq) != 'a')
     610:	f9040693          	addi	a3,s0,-112
     614:	f9840613          	addi	a2,s0,-104
     618:	85ca                	mv	a1,s2
     61a:	854e                	mv	a0,s3
     61c:	00000097          	auipc	ra,0x0
     620:	dc2080e7          	jalr	-574(ra) # 3de <gettoken>
     624:	f9851de3          	bne	a0,s8,5be <parseredirs+0x32>
        switch (tok)
     628:	fb9483e3          	beq	s1,s9,5ce <parseredirs+0x42>
     62c:	03648263          	beq	s1,s6,650 <parseredirs+0xc4>
     630:	fb549fe3          	bne	s1,s5,5ee <parseredirs+0x62>
            break;
        case '>':
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE | O_TRUNC, 1);
            break;
        case '+': // >>
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE, 1);
     634:	4705                	li	a4,1
     636:	20100693          	li	a3,513
     63a:	f9043603          	ld	a2,-112(s0)
     63e:	f9843583          	ld	a1,-104(s0)
     642:	8552                	mv	a0,s4
     644:	00000097          	auipc	ra,0x0
     648:	c6a080e7          	jalr	-918(ra) # 2ae <redircmd>
     64c:	8a2a                	mv	s4,a0
            break;
     64e:	bf61                	j	5e6 <parseredirs+0x5a>
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE | O_TRUNC, 1);
     650:	4705                	li	a4,1
     652:	60100693          	li	a3,1537
     656:	f9043603          	ld	a2,-112(s0)
     65a:	f9843583          	ld	a1,-104(s0)
     65e:	8552                	mv	a0,s4
     660:	00000097          	auipc	ra,0x0
     664:	c4e080e7          	jalr	-946(ra) # 2ae <redircmd>
     668:	8a2a                	mv	s4,a0
            break;
     66a:	bfb5                	j	5e6 <parseredirs+0x5a>
        }
    }
    return cmd;
}
     66c:	8552                	mv	a0,s4
     66e:	70a6                	ld	ra,104(sp)
     670:	7406                	ld	s0,96(sp)
     672:	64e6                	ld	s1,88(sp)
     674:	6946                	ld	s2,80(sp)
     676:	69a6                	ld	s3,72(sp)
     678:	6a06                	ld	s4,64(sp)
     67a:	7ae2                	ld	s5,56(sp)
     67c:	7b42                	ld	s6,48(sp)
     67e:	7ba2                	ld	s7,40(sp)
     680:	7c02                	ld	s8,32(sp)
     682:	6ce2                	ld	s9,24(sp)
     684:	6165                	addi	sp,sp,112
     686:	8082                	ret

0000000000000688 <parseexec>:
    return cmd;
}

struct cmd *
parseexec(char **ps, char *es)
{
     688:	7159                	addi	sp,sp,-112
     68a:	f486                	sd	ra,104(sp)
     68c:	f0a2                	sd	s0,96(sp)
     68e:	eca6                	sd	s1,88(sp)
     690:	e8ca                	sd	s2,80(sp)
     692:	e4ce                	sd	s3,72(sp)
     694:	e0d2                	sd	s4,64(sp)
     696:	fc56                	sd	s5,56(sp)
     698:	f85a                	sd	s6,48(sp)
     69a:	f45e                	sd	s7,40(sp)
     69c:	f062                	sd	s8,32(sp)
     69e:	ec66                	sd	s9,24(sp)
     6a0:	1880                	addi	s0,sp,112
     6a2:	8a2a                	mv	s4,a0
     6a4:	8aae                	mv	s5,a1
    char *q, *eq;
    int tok, argc;
    struct execcmd *cmd;
    struct cmd *ret;

    if (peek(ps, es, "("))
     6a6:	00001617          	auipc	a2,0x1
     6aa:	dba60613          	addi	a2,a2,-582 # 1460 <malloc+0x15e>
     6ae:	00000097          	auipc	ra,0x0
     6b2:	e72080e7          	jalr	-398(ra) # 520 <peek>
     6b6:	e905                	bnez	a0,6e6 <parseexec+0x5e>
     6b8:	89aa                	mv	s3,a0
        return parseblock(ps, es);

    ret = execcmd();
     6ba:	00000097          	auipc	ra,0x0
     6be:	bbe080e7          	jalr	-1090(ra) # 278 <execcmd>
     6c2:	8c2a                	mv	s8,a0
    cmd = (struct execcmd *)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
     6c4:	8656                	mv	a2,s5
     6c6:	85d2                	mv	a1,s4
     6c8:	00000097          	auipc	ra,0x0
     6cc:	ec4080e7          	jalr	-316(ra) # 58c <parseredirs>
     6d0:	84aa                	mv	s1,a0
    while (!peek(ps, es, "|)&;"))
     6d2:	008c0913          	addi	s2,s8,8
     6d6:	00001b17          	auipc	s6,0x1
     6da:	daab0b13          	addi	s6,s6,-598 # 1480 <malloc+0x17e>
    {
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
            break;
        if (tok != 'a')
     6de:	06100c93          	li	s9,97
            panic("syntax");
        cmd->argv[argc] = q;
        cmd->eargv[argc] = eq;
        argc++;
        if (argc >= MAXARGS)
     6e2:	4ba9                	li	s7,10
    while (!peek(ps, es, "|)&;"))
     6e4:	a0b1                	j	730 <parseexec+0xa8>
        return parseblock(ps, es);
     6e6:	85d6                	mv	a1,s5
     6e8:	8552                	mv	a0,s4
     6ea:	00000097          	auipc	ra,0x0
     6ee:	1bc080e7          	jalr	444(ra) # 8a6 <parseblock>
     6f2:	84aa                	mv	s1,a0
        ret = parseredirs(ret, ps, es);
    }
    cmd->argv[argc] = 0;
    cmd->eargv[argc] = 0;
    return ret;
}
     6f4:	8526                	mv	a0,s1
     6f6:	70a6                	ld	ra,104(sp)
     6f8:	7406                	ld	s0,96(sp)
     6fa:	64e6                	ld	s1,88(sp)
     6fc:	6946                	ld	s2,80(sp)
     6fe:	69a6                	ld	s3,72(sp)
     700:	6a06                	ld	s4,64(sp)
     702:	7ae2                	ld	s5,56(sp)
     704:	7b42                	ld	s6,48(sp)
     706:	7ba2                	ld	s7,40(sp)
     708:	7c02                	ld	s8,32(sp)
     70a:	6ce2                	ld	s9,24(sp)
     70c:	6165                	addi	sp,sp,112
     70e:	8082                	ret
            panic("syntax");
     710:	00001517          	auipc	a0,0x1
     714:	d5850513          	addi	a0,a0,-680 # 1468 <malloc+0x166>
     718:	00000097          	auipc	ra,0x0
     71c:	93e080e7          	jalr	-1730(ra) # 56 <panic>
        ret = parseredirs(ret, ps, es);
     720:	8656                	mv	a2,s5
     722:	85d2                	mv	a1,s4
     724:	8526                	mv	a0,s1
     726:	00000097          	auipc	ra,0x0
     72a:	e66080e7          	jalr	-410(ra) # 58c <parseredirs>
     72e:	84aa                	mv	s1,a0
    while (!peek(ps, es, "|)&;"))
     730:	865a                	mv	a2,s6
     732:	85d6                	mv	a1,s5
     734:	8552                	mv	a0,s4
     736:	00000097          	auipc	ra,0x0
     73a:	dea080e7          	jalr	-534(ra) # 520 <peek>
     73e:	e131                	bnez	a0,782 <parseexec+0xfa>
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
     740:	f9040693          	addi	a3,s0,-112
     744:	f9840613          	addi	a2,s0,-104
     748:	85d6                	mv	a1,s5
     74a:	8552                	mv	a0,s4
     74c:	00000097          	auipc	ra,0x0
     750:	c92080e7          	jalr	-878(ra) # 3de <gettoken>
     754:	c51d                	beqz	a0,782 <parseexec+0xfa>
        if (tok != 'a')
     756:	fb951de3          	bne	a0,s9,710 <parseexec+0x88>
        cmd->argv[argc] = q;
     75a:	f9843783          	ld	a5,-104(s0)
     75e:	00f93023          	sd	a5,0(s2)
        cmd->eargv[argc] = eq;
     762:	f9043783          	ld	a5,-112(s0)
     766:	04f93823          	sd	a5,80(s2)
        argc++;
     76a:	2985                	addiw	s3,s3,1
        if (argc >= MAXARGS)
     76c:	0921                	addi	s2,s2,8
     76e:	fb7999e3          	bne	s3,s7,720 <parseexec+0x98>
            panic("too many args");
     772:	00001517          	auipc	a0,0x1
     776:	cfe50513          	addi	a0,a0,-770 # 1470 <malloc+0x16e>
     77a:	00000097          	auipc	ra,0x0
     77e:	8dc080e7          	jalr	-1828(ra) # 56 <panic>
    cmd->argv[argc] = 0;
     782:	098e                	slli	s3,s3,0x3
     784:	9c4e                	add	s8,s8,s3
     786:	000c3423          	sd	zero,8(s8)
    cmd->eargv[argc] = 0;
     78a:	040c3c23          	sd	zero,88(s8)
    return ret;
     78e:	b79d                	j	6f4 <parseexec+0x6c>

0000000000000790 <parsepipe>:
{
     790:	7179                	addi	sp,sp,-48
     792:	f406                	sd	ra,40(sp)
     794:	f022                	sd	s0,32(sp)
     796:	ec26                	sd	s1,24(sp)
     798:	e84a                	sd	s2,16(sp)
     79a:	e44e                	sd	s3,8(sp)
     79c:	1800                	addi	s0,sp,48
     79e:	892a                	mv	s2,a0
     7a0:	89ae                	mv	s3,a1
    cmd = parseexec(ps, es);
     7a2:	00000097          	auipc	ra,0x0
     7a6:	ee6080e7          	jalr	-282(ra) # 688 <parseexec>
     7aa:	84aa                	mv	s1,a0
    if (peek(ps, es, "|"))
     7ac:	00001617          	auipc	a2,0x1
     7b0:	cdc60613          	addi	a2,a2,-804 # 1488 <malloc+0x186>
     7b4:	85ce                	mv	a1,s3
     7b6:	854a                	mv	a0,s2
     7b8:	00000097          	auipc	ra,0x0
     7bc:	d68080e7          	jalr	-664(ra) # 520 <peek>
     7c0:	e909                	bnez	a0,7d2 <parsepipe+0x42>
}
     7c2:	8526                	mv	a0,s1
     7c4:	70a2                	ld	ra,40(sp)
     7c6:	7402                	ld	s0,32(sp)
     7c8:	64e2                	ld	s1,24(sp)
     7ca:	6942                	ld	s2,16(sp)
     7cc:	69a2                	ld	s3,8(sp)
     7ce:	6145                	addi	sp,sp,48
     7d0:	8082                	ret
        gettoken(ps, es, 0, 0);
     7d2:	4681                	li	a3,0
     7d4:	4601                	li	a2,0
     7d6:	85ce                	mv	a1,s3
     7d8:	854a                	mv	a0,s2
     7da:	00000097          	auipc	ra,0x0
     7de:	c04080e7          	jalr	-1020(ra) # 3de <gettoken>
        cmd = pipecmd(cmd, parsepipe(ps, es));
     7e2:	85ce                	mv	a1,s3
     7e4:	854a                	mv	a0,s2
     7e6:	00000097          	auipc	ra,0x0
     7ea:	faa080e7          	jalr	-86(ra) # 790 <parsepipe>
     7ee:	85aa                	mv	a1,a0
     7f0:	8526                	mv	a0,s1
     7f2:	00000097          	auipc	ra,0x0
     7f6:	b24080e7          	jalr	-1244(ra) # 316 <pipecmd>
     7fa:	84aa                	mv	s1,a0
    return cmd;
     7fc:	b7d9                	j	7c2 <parsepipe+0x32>

00000000000007fe <parseline>:
{
     7fe:	7179                	addi	sp,sp,-48
     800:	f406                	sd	ra,40(sp)
     802:	f022                	sd	s0,32(sp)
     804:	ec26                	sd	s1,24(sp)
     806:	e84a                	sd	s2,16(sp)
     808:	e44e                	sd	s3,8(sp)
     80a:	e052                	sd	s4,0(sp)
     80c:	1800                	addi	s0,sp,48
     80e:	892a                	mv	s2,a0
     810:	89ae                	mv	s3,a1
    cmd = parsepipe(ps, es);
     812:	00000097          	auipc	ra,0x0
     816:	f7e080e7          	jalr	-130(ra) # 790 <parsepipe>
     81a:	84aa                	mv	s1,a0
    while (peek(ps, es, "&"))
     81c:	00001a17          	auipc	s4,0x1
     820:	c74a0a13          	addi	s4,s4,-908 # 1490 <malloc+0x18e>
     824:	a839                	j	842 <parseline+0x44>
        gettoken(ps, es, 0, 0);
     826:	4681                	li	a3,0
     828:	4601                	li	a2,0
     82a:	85ce                	mv	a1,s3
     82c:	854a                	mv	a0,s2
     82e:	00000097          	auipc	ra,0x0
     832:	bb0080e7          	jalr	-1104(ra) # 3de <gettoken>
        cmd = backcmd(cmd);
     836:	8526                	mv	a0,s1
     838:	00000097          	auipc	ra,0x0
     83c:	b6a080e7          	jalr	-1174(ra) # 3a2 <backcmd>
     840:	84aa                	mv	s1,a0
    while (peek(ps, es, "&"))
     842:	8652                	mv	a2,s4
     844:	85ce                	mv	a1,s3
     846:	854a                	mv	a0,s2
     848:	00000097          	auipc	ra,0x0
     84c:	cd8080e7          	jalr	-808(ra) # 520 <peek>
     850:	f979                	bnez	a0,826 <parseline+0x28>
    if (peek(ps, es, ";"))
     852:	00001617          	auipc	a2,0x1
     856:	c4660613          	addi	a2,a2,-954 # 1498 <malloc+0x196>
     85a:	85ce                	mv	a1,s3
     85c:	854a                	mv	a0,s2
     85e:	00000097          	auipc	ra,0x0
     862:	cc2080e7          	jalr	-830(ra) # 520 <peek>
     866:	e911                	bnez	a0,87a <parseline+0x7c>
}
     868:	8526                	mv	a0,s1
     86a:	70a2                	ld	ra,40(sp)
     86c:	7402                	ld	s0,32(sp)
     86e:	64e2                	ld	s1,24(sp)
     870:	6942                	ld	s2,16(sp)
     872:	69a2                	ld	s3,8(sp)
     874:	6a02                	ld	s4,0(sp)
     876:	6145                	addi	sp,sp,48
     878:	8082                	ret
        gettoken(ps, es, 0, 0);
     87a:	4681                	li	a3,0
     87c:	4601                	li	a2,0
     87e:	85ce                	mv	a1,s3
     880:	854a                	mv	a0,s2
     882:	00000097          	auipc	ra,0x0
     886:	b5c080e7          	jalr	-1188(ra) # 3de <gettoken>
        cmd = listcmd(cmd, parseline(ps, es));
     88a:	85ce                	mv	a1,s3
     88c:	854a                	mv	a0,s2
     88e:	00000097          	auipc	ra,0x0
     892:	f70080e7          	jalr	-144(ra) # 7fe <parseline>
     896:	85aa                	mv	a1,a0
     898:	8526                	mv	a0,s1
     89a:	00000097          	auipc	ra,0x0
     89e:	ac2080e7          	jalr	-1342(ra) # 35c <listcmd>
     8a2:	84aa                	mv	s1,a0
    return cmd;
     8a4:	b7d1                	j	868 <parseline+0x6a>

00000000000008a6 <parseblock>:
{
     8a6:	7179                	addi	sp,sp,-48
     8a8:	f406                	sd	ra,40(sp)
     8aa:	f022                	sd	s0,32(sp)
     8ac:	ec26                	sd	s1,24(sp)
     8ae:	e84a                	sd	s2,16(sp)
     8b0:	e44e                	sd	s3,8(sp)
     8b2:	1800                	addi	s0,sp,48
     8b4:	84aa                	mv	s1,a0
     8b6:	892e                	mv	s2,a1
    if (!peek(ps, es, "("))
     8b8:	00001617          	auipc	a2,0x1
     8bc:	ba860613          	addi	a2,a2,-1112 # 1460 <malloc+0x15e>
     8c0:	00000097          	auipc	ra,0x0
     8c4:	c60080e7          	jalr	-928(ra) # 520 <peek>
     8c8:	c12d                	beqz	a0,92a <parseblock+0x84>
    gettoken(ps, es, 0, 0);
     8ca:	4681                	li	a3,0
     8cc:	4601                	li	a2,0
     8ce:	85ca                	mv	a1,s2
     8d0:	8526                	mv	a0,s1
     8d2:	00000097          	auipc	ra,0x0
     8d6:	b0c080e7          	jalr	-1268(ra) # 3de <gettoken>
    cmd = parseline(ps, es);
     8da:	85ca                	mv	a1,s2
     8dc:	8526                	mv	a0,s1
     8de:	00000097          	auipc	ra,0x0
     8e2:	f20080e7          	jalr	-224(ra) # 7fe <parseline>
     8e6:	89aa                	mv	s3,a0
    if (!peek(ps, es, ")"))
     8e8:	00001617          	auipc	a2,0x1
     8ec:	bc860613          	addi	a2,a2,-1080 # 14b0 <malloc+0x1ae>
     8f0:	85ca                	mv	a1,s2
     8f2:	8526                	mv	a0,s1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	c2c080e7          	jalr	-980(ra) # 520 <peek>
     8fc:	cd1d                	beqz	a0,93a <parseblock+0x94>
    gettoken(ps, es, 0, 0);
     8fe:	4681                	li	a3,0
     900:	4601                	li	a2,0
     902:	85ca                	mv	a1,s2
     904:	8526                	mv	a0,s1
     906:	00000097          	auipc	ra,0x0
     90a:	ad8080e7          	jalr	-1320(ra) # 3de <gettoken>
    cmd = parseredirs(cmd, ps, es);
     90e:	864a                	mv	a2,s2
     910:	85a6                	mv	a1,s1
     912:	854e                	mv	a0,s3
     914:	00000097          	auipc	ra,0x0
     918:	c78080e7          	jalr	-904(ra) # 58c <parseredirs>
}
     91c:	70a2                	ld	ra,40(sp)
     91e:	7402                	ld	s0,32(sp)
     920:	64e2                	ld	s1,24(sp)
     922:	6942                	ld	s2,16(sp)
     924:	69a2                	ld	s3,8(sp)
     926:	6145                	addi	sp,sp,48
     928:	8082                	ret
        panic("parseblock");
     92a:	00001517          	auipc	a0,0x1
     92e:	b7650513          	addi	a0,a0,-1162 # 14a0 <malloc+0x19e>
     932:	fffff097          	auipc	ra,0xfffff
     936:	724080e7          	jalr	1828(ra) # 56 <panic>
        panic("syntax - missing )");
     93a:	00001517          	auipc	a0,0x1
     93e:	b7e50513          	addi	a0,a0,-1154 # 14b8 <malloc+0x1b6>
     942:	fffff097          	auipc	ra,0xfffff
     946:	714080e7          	jalr	1812(ra) # 56 <panic>

000000000000094a <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd *
nulterminate(struct cmd *cmd)
{
     94a:	1101                	addi	sp,sp,-32
     94c:	ec06                	sd	ra,24(sp)
     94e:	e822                	sd	s0,16(sp)
     950:	e426                	sd	s1,8(sp)
     952:	1000                	addi	s0,sp,32
     954:	84aa                	mv	s1,a0
    struct execcmd *ecmd;
    struct listcmd *lcmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;

    if (cmd == 0)
     956:	c521                	beqz	a0,99e <nulterminate+0x54>
        return 0;

    switch (cmd->type)
     958:	4118                	lw	a4,0(a0)
     95a:	4795                	li	a5,5
     95c:	04e7e163          	bltu	a5,a4,99e <nulterminate+0x54>
     960:	00056783          	lwu	a5,0(a0)
     964:	078a                	slli	a5,a5,0x2
     966:	00001717          	auipc	a4,0x1
     96a:	bc670713          	addi	a4,a4,-1082 # 152c <malloc+0x22a>
     96e:	97ba                	add	a5,a5,a4
     970:	439c                	lw	a5,0(a5)
     972:	97ba                	add	a5,a5,a4
     974:	8782                	jr	a5
    {
    case EXEC:
        ecmd = (struct execcmd *)cmd;
        for (i = 0; ecmd->argv[i]; i++)
     976:	651c                	ld	a5,8(a0)
     978:	c39d                	beqz	a5,99e <nulterminate+0x54>
     97a:	01050793          	addi	a5,a0,16
            *ecmd->eargv[i] = 0;
     97e:	67b8                	ld	a4,72(a5)
     980:	00070023          	sb	zero,0(a4)
        for (i = 0; ecmd->argv[i]; i++)
     984:	07a1                	addi	a5,a5,8
     986:	ff87b703          	ld	a4,-8(a5)
     98a:	fb75                	bnez	a4,97e <nulterminate+0x34>
     98c:	a809                	j	99e <nulterminate+0x54>
        break;

    case REDIR:
        rcmd = (struct redircmd *)cmd;
        nulterminate(rcmd->cmd);
     98e:	6508                	ld	a0,8(a0)
     990:	00000097          	auipc	ra,0x0
     994:	fba080e7          	jalr	-70(ra) # 94a <nulterminate>
        *rcmd->efile = 0;
     998:	6c9c                	ld	a5,24(s1)
     99a:	00078023          	sb	zero,0(a5)
        bcmd = (struct backcmd *)cmd;
        nulterminate(bcmd->cmd);
        break;
    }
    return cmd;
}
     99e:	8526                	mv	a0,s1
     9a0:	60e2                	ld	ra,24(sp)
     9a2:	6442                	ld	s0,16(sp)
     9a4:	64a2                	ld	s1,8(sp)
     9a6:	6105                	addi	sp,sp,32
     9a8:	8082                	ret
        nulterminate(pcmd->left);
     9aa:	6508                	ld	a0,8(a0)
     9ac:	00000097          	auipc	ra,0x0
     9b0:	f9e080e7          	jalr	-98(ra) # 94a <nulterminate>
        nulterminate(pcmd->right);
     9b4:	6888                	ld	a0,16(s1)
     9b6:	00000097          	auipc	ra,0x0
     9ba:	f94080e7          	jalr	-108(ra) # 94a <nulterminate>
        break;
     9be:	b7c5                	j	99e <nulterminate+0x54>
        nulterminate(lcmd->left);
     9c0:	6508                	ld	a0,8(a0)
     9c2:	00000097          	auipc	ra,0x0
     9c6:	f88080e7          	jalr	-120(ra) # 94a <nulterminate>
        nulterminate(lcmd->right);
     9ca:	6888                	ld	a0,16(s1)
     9cc:	00000097          	auipc	ra,0x0
     9d0:	f7e080e7          	jalr	-130(ra) # 94a <nulterminate>
        break;
     9d4:	b7e9                	j	99e <nulterminate+0x54>
        nulterminate(bcmd->cmd);
     9d6:	6508                	ld	a0,8(a0)
     9d8:	00000097          	auipc	ra,0x0
     9dc:	f72080e7          	jalr	-142(ra) # 94a <nulterminate>
        break;
     9e0:	bf7d                	j	99e <nulterminate+0x54>

00000000000009e2 <parsecmd>:
{
     9e2:	7179                	addi	sp,sp,-48
     9e4:	f406                	sd	ra,40(sp)
     9e6:	f022                	sd	s0,32(sp)
     9e8:	ec26                	sd	s1,24(sp)
     9ea:	e84a                	sd	s2,16(sp)
     9ec:	1800                	addi	s0,sp,48
     9ee:	fca43c23          	sd	a0,-40(s0)
    es = s + strlen(s);
     9f2:	84aa                	mv	s1,a0
     9f4:	00000097          	auipc	ra,0x0
     9f8:	290080e7          	jalr	656(ra) # c84 <strlen>
     9fc:	1502                	slli	a0,a0,0x20
     9fe:	9101                	srli	a0,a0,0x20
     a00:	94aa                	add	s1,s1,a0
    cmd = parseline(&s, es);
     a02:	85a6                	mv	a1,s1
     a04:	fd840513          	addi	a0,s0,-40
     a08:	00000097          	auipc	ra,0x0
     a0c:	df6080e7          	jalr	-522(ra) # 7fe <parseline>
     a10:	892a                	mv	s2,a0
    peek(&s, es, "");
     a12:	00001617          	auipc	a2,0x1
     a16:	abe60613          	addi	a2,a2,-1346 # 14d0 <malloc+0x1ce>
     a1a:	85a6                	mv	a1,s1
     a1c:	fd840513          	addi	a0,s0,-40
     a20:	00000097          	auipc	ra,0x0
     a24:	b00080e7          	jalr	-1280(ra) # 520 <peek>
    if (s != es)
     a28:	fd843603          	ld	a2,-40(s0)
     a2c:	00961e63          	bne	a2,s1,a48 <parsecmd+0x66>
    nulterminate(cmd);
     a30:	854a                	mv	a0,s2
     a32:	00000097          	auipc	ra,0x0
     a36:	f18080e7          	jalr	-232(ra) # 94a <nulterminate>
}
     a3a:	854a                	mv	a0,s2
     a3c:	70a2                	ld	ra,40(sp)
     a3e:	7402                	ld	s0,32(sp)
     a40:	64e2                	ld	s1,24(sp)
     a42:	6942                	ld	s2,16(sp)
     a44:	6145                	addi	sp,sp,48
     a46:	8082                	ret
        fprintf(2, "leftovers: %s\n", s);
     a48:	00001597          	auipc	a1,0x1
     a4c:	a9058593          	addi	a1,a1,-1392 # 14d8 <malloc+0x1d6>
     a50:	4509                	li	a0,2
     a52:	00000097          	auipc	ra,0x0
     a56:	7ca080e7          	jalr	1994(ra) # 121c <fprintf>
        panic("syntax");
     a5a:	00001517          	auipc	a0,0x1
     a5e:	a0e50513          	addi	a0,a0,-1522 # 1468 <malloc+0x166>
     a62:	fffff097          	auipc	ra,0xfffff
     a66:	5f4080e7          	jalr	1524(ra) # 56 <panic>

0000000000000a6a <parse_buffer>:
{
     a6a:	1101                	addi	sp,sp,-32
     a6c:	ec06                	sd	ra,24(sp)
     a6e:	e822                	sd	s0,16(sp)
     a70:	e426                	sd	s1,8(sp)
     a72:	1000                	addi	s0,sp,32
     a74:	84aa                	mv	s1,a0
    if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ')
     a76:	00054783          	lbu	a5,0(a0)
     a7a:	06300713          	li	a4,99
     a7e:	02e78b63          	beq	a5,a4,ab4 <parse_buffer+0x4a>
    if (buf[0] == 'e' &&
     a82:	06500713          	li	a4,101
     a86:	00e79863          	bne	a5,a4,a96 <parse_buffer+0x2c>
     a8a:	00154703          	lbu	a4,1(a0)
     a8e:	07800793          	li	a5,120
     a92:	06f70b63          	beq	a4,a5,b08 <parse_buffer+0x9e>
    if (fork1() == 0)
     a96:	fffff097          	auipc	ra,0xfffff
     a9a:	5e6080e7          	jalr	1510(ra) # 7c <fork1>
     a9e:	c551                	beqz	a0,b2a <parse_buffer+0xc0>
    wait(0);
     aa0:	4501                	li	a0,0
     aa2:	00000097          	auipc	ra,0x0
     aa6:	40e080e7          	jalr	1038(ra) # eb0 <wait>
}
     aaa:	60e2                	ld	ra,24(sp)
     aac:	6442                	ld	s0,16(sp)
     aae:	64a2                	ld	s1,8(sp)
     ab0:	6105                	addi	sp,sp,32
     ab2:	8082                	ret
    if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ')
     ab4:	00154703          	lbu	a4,1(a0)
     ab8:	06400793          	li	a5,100
     abc:	fcf71de3          	bne	a4,a5,a96 <parse_buffer+0x2c>
     ac0:	00254703          	lbu	a4,2(a0)
     ac4:	02000793          	li	a5,32
     ac8:	fcf717e3          	bne	a4,a5,a96 <parse_buffer+0x2c>
        buf[strlen(buf) - 1] = 0; // chop \n
     acc:	00000097          	auipc	ra,0x0
     ad0:	1b8080e7          	jalr	440(ra) # c84 <strlen>
     ad4:	fff5079b          	addiw	a5,a0,-1
     ad8:	1782                	slli	a5,a5,0x20
     ada:	9381                	srli	a5,a5,0x20
     adc:	97a6                	add	a5,a5,s1
     ade:	00078023          	sb	zero,0(a5)
        if (chdir(buf + 3) < 0)
     ae2:	048d                	addi	s1,s1,3
     ae4:	8526                	mv	a0,s1
     ae6:	00000097          	auipc	ra,0x0
     aea:	432080e7          	jalr	1074(ra) # f18 <chdir>
     aee:	fa055ee3          	bgez	a0,aaa <parse_buffer+0x40>
            fprintf(2, "cannot cd %s\n", buf + 3);
     af2:	8626                	mv	a2,s1
     af4:	00001597          	auipc	a1,0x1
     af8:	9f458593          	addi	a1,a1,-1548 # 14e8 <malloc+0x1e6>
     afc:	4509                	li	a0,2
     afe:	00000097          	auipc	ra,0x0
     b02:	71e080e7          	jalr	1822(ra) # 121c <fprintf>
     b06:	b755                	j	aaa <parse_buffer+0x40>
        buf[1] == 'x' &&
     b08:	00254703          	lbu	a4,2(a0)
     b0c:	06900793          	li	a5,105
     b10:	f8f713e3          	bne	a4,a5,a96 <parse_buffer+0x2c>
        buf[2] == 'i' &&
     b14:	00354703          	lbu	a4,3(a0)
     b18:	07400793          	li	a5,116
     b1c:	f6f71de3          	bne	a4,a5,a96 <parse_buffer+0x2c>
        exit(0);
     b20:	4501                	li	a0,0
     b22:	00000097          	auipc	ra,0x0
     b26:	386080e7          	jalr	902(ra) # ea8 <exit>
        runcmd(parsecmd(buf));
     b2a:	8526                	mv	a0,s1
     b2c:	00000097          	auipc	ra,0x0
     b30:	eb6080e7          	jalr	-330(ra) # 9e2 <parsecmd>
     b34:	fffff097          	auipc	ra,0xfffff
     b38:	576080e7          	jalr	1398(ra) # aa <runcmd>

0000000000000b3c <main>:
{
     b3c:	7179                	addi	sp,sp,-48
     b3e:	f406                	sd	ra,40(sp)
     b40:	f022                	sd	s0,32(sp)
     b42:	ec26                	sd	s1,24(sp)
     b44:	e84a                	sd	s2,16(sp)
     b46:	e44e                	sd	s3,8(sp)
     b48:	1800                	addi	s0,sp,48
     b4a:	892a                	mv	s2,a0
     b4c:	89ae                	mv	s3,a1
    while ((fd = open("console", O_RDWR)) >= 0)
     b4e:	00001497          	auipc	s1,0x1
     b52:	9aa48493          	addi	s1,s1,-1622 # 14f8 <malloc+0x1f6>
     b56:	4589                	li	a1,2
     b58:	8526                	mv	a0,s1
     b5a:	00000097          	auipc	ra,0x0
     b5e:	38e080e7          	jalr	910(ra) # ee8 <open>
     b62:	00054963          	bltz	a0,b74 <main+0x38>
        if (fd >= 3)
     b66:	4789                	li	a5,2
     b68:	fea7d7e3          	bge	a5,a0,b56 <main+0x1a>
            close(fd);
     b6c:	00000097          	auipc	ra,0x0
     b70:	364080e7          	jalr	868(ra) # ed0 <close>
    if (argc == 2)
     b74:	4789                	li	a5,2
    while (getcmd(buf, sizeof(buf)) >= 0)
     b76:	00001497          	auipc	s1,0x1
     b7a:	4aa48493          	addi	s1,s1,1194 # 2020 <buf.0>
    if (argc == 2)
     b7e:	08f91463          	bne	s2,a5,c06 <main+0xca>
        char *shell_script_file = argv[1];
     b82:	0089b483          	ld	s1,8(s3)
        int shfd = open(shell_script_file, O_RDWR);
     b86:	4589                	li	a1,2
     b88:	8526                	mv	a0,s1
     b8a:	00000097          	auipc	ra,0x0
     b8e:	35e080e7          	jalr	862(ra) # ee8 <open>
     b92:	892a                	mv	s2,a0
        if (shfd < 0)
     b94:	04054663          	bltz	a0,be0 <main+0xa4>
        read(shfd, buf, sizeof(buf));
     b98:	07800613          	li	a2,120
     b9c:	00001597          	auipc	a1,0x1
     ba0:	48458593          	addi	a1,a1,1156 # 2020 <buf.0>
     ba4:	00000097          	auipc	ra,0x0
     ba8:	31c080e7          	jalr	796(ra) # ec0 <read>
            parse_buffer(buf);
     bac:	00001497          	auipc	s1,0x1
     bb0:	47448493          	addi	s1,s1,1140 # 2020 <buf.0>
     bb4:	8526                	mv	a0,s1
     bb6:	00000097          	auipc	ra,0x0
     bba:	eb4080e7          	jalr	-332(ra) # a6a <parse_buffer>
        } while (read(shfd, buf, sizeof(buf)) == sizeof(buf));
     bbe:	07800613          	li	a2,120
     bc2:	85a6                	mv	a1,s1
     bc4:	854a                	mv	a0,s2
     bc6:	00000097          	auipc	ra,0x0
     bca:	2fa080e7          	jalr	762(ra) # ec0 <read>
     bce:	07800793          	li	a5,120
     bd2:	fef501e3          	beq	a0,a5,bb4 <main+0x78>
        exit(0);
     bd6:	4501                	li	a0,0
     bd8:	00000097          	auipc	ra,0x0
     bdc:	2d0080e7          	jalr	720(ra) # ea8 <exit>
            printf("Failed to open %s\n", shell_script_file);
     be0:	85a6                	mv	a1,s1
     be2:	00001517          	auipc	a0,0x1
     be6:	91e50513          	addi	a0,a0,-1762 # 1500 <malloc+0x1fe>
     bea:	00000097          	auipc	ra,0x0
     bee:	660080e7          	jalr	1632(ra) # 124a <printf>
            exit(1);
     bf2:	4505                	li	a0,1
     bf4:	00000097          	auipc	ra,0x0
     bf8:	2b4080e7          	jalr	692(ra) # ea8 <exit>
        parse_buffer(buf);
     bfc:	8526                	mv	a0,s1
     bfe:	00000097          	auipc	ra,0x0
     c02:	e6c080e7          	jalr	-404(ra) # a6a <parse_buffer>
    while (getcmd(buf, sizeof(buf)) >= 0)
     c06:	07800593          	li	a1,120
     c0a:	8526                	mv	a0,s1
     c0c:	fffff097          	auipc	ra,0xfffff
     c10:	3f4080e7          	jalr	1012(ra) # 0 <getcmd>
     c14:	fe0554e3          	bgez	a0,bfc <main+0xc0>
    exit(0);
     c18:	4501                	li	a0,0
     c1a:	00000097          	auipc	ra,0x0
     c1e:	28e080e7          	jalr	654(ra) # ea8 <exit>

0000000000000c22 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     c22:	1141                	addi	sp,sp,-16
     c24:	e406                	sd	ra,8(sp)
     c26:	e022                	sd	s0,0(sp)
     c28:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c2a:	00000097          	auipc	ra,0x0
     c2e:	f12080e7          	jalr	-238(ra) # b3c <main>
  exit(0);
     c32:	4501                	li	a0,0
     c34:	00000097          	auipc	ra,0x0
     c38:	274080e7          	jalr	628(ra) # ea8 <exit>

0000000000000c3c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c3c:	1141                	addi	sp,sp,-16
     c3e:	e422                	sd	s0,8(sp)
     c40:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c42:	87aa                	mv	a5,a0
     c44:	0585                	addi	a1,a1,1
     c46:	0785                	addi	a5,a5,1
     c48:	fff5c703          	lbu	a4,-1(a1)
     c4c:	fee78fa3          	sb	a4,-1(a5)
     c50:	fb75                	bnez	a4,c44 <strcpy+0x8>
    ;
  return os;
}
     c52:	6422                	ld	s0,8(sp)
     c54:	0141                	addi	sp,sp,16
     c56:	8082                	ret

0000000000000c58 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c58:	1141                	addi	sp,sp,-16
     c5a:	e422                	sd	s0,8(sp)
     c5c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c5e:	00054783          	lbu	a5,0(a0)
     c62:	cb91                	beqz	a5,c76 <strcmp+0x1e>
     c64:	0005c703          	lbu	a4,0(a1)
     c68:	00f71763          	bne	a4,a5,c76 <strcmp+0x1e>
    p++, q++;
     c6c:	0505                	addi	a0,a0,1
     c6e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c70:	00054783          	lbu	a5,0(a0)
     c74:	fbe5                	bnez	a5,c64 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c76:	0005c503          	lbu	a0,0(a1)
}
     c7a:	40a7853b          	subw	a0,a5,a0
     c7e:	6422                	ld	s0,8(sp)
     c80:	0141                	addi	sp,sp,16
     c82:	8082                	ret

0000000000000c84 <strlen>:

uint
strlen(const char *s)
{
     c84:	1141                	addi	sp,sp,-16
     c86:	e422                	sd	s0,8(sp)
     c88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c8a:	00054783          	lbu	a5,0(a0)
     c8e:	cf91                	beqz	a5,caa <strlen+0x26>
     c90:	0505                	addi	a0,a0,1
     c92:	87aa                	mv	a5,a0
     c94:	4685                	li	a3,1
     c96:	9e89                	subw	a3,a3,a0
     c98:	00f6853b          	addw	a0,a3,a5
     c9c:	0785                	addi	a5,a5,1
     c9e:	fff7c703          	lbu	a4,-1(a5)
     ca2:	fb7d                	bnez	a4,c98 <strlen+0x14>
    ;
  return n;
}
     ca4:	6422                	ld	s0,8(sp)
     ca6:	0141                	addi	sp,sp,16
     ca8:	8082                	ret
  for(n = 0; s[n]; n++)
     caa:	4501                	li	a0,0
     cac:	bfe5                	j	ca4 <strlen+0x20>

0000000000000cae <memset>:

void*
memset(void *dst, int c, uint n)
{
     cae:	1141                	addi	sp,sp,-16
     cb0:	e422                	sd	s0,8(sp)
     cb2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     cb4:	ca19                	beqz	a2,cca <memset+0x1c>
     cb6:	87aa                	mv	a5,a0
     cb8:	1602                	slli	a2,a2,0x20
     cba:	9201                	srli	a2,a2,0x20
     cbc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     cc0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cc4:	0785                	addi	a5,a5,1
     cc6:	fee79de3          	bne	a5,a4,cc0 <memset+0x12>
  }
  return dst;
}
     cca:	6422                	ld	s0,8(sp)
     ccc:	0141                	addi	sp,sp,16
     cce:	8082                	ret

0000000000000cd0 <strchr>:

char*
strchr(const char *s, char c)
{
     cd0:	1141                	addi	sp,sp,-16
     cd2:	e422                	sd	s0,8(sp)
     cd4:	0800                	addi	s0,sp,16
  for(; *s; s++)
     cd6:	00054783          	lbu	a5,0(a0)
     cda:	cb99                	beqz	a5,cf0 <strchr+0x20>
    if(*s == c)
     cdc:	00f58763          	beq	a1,a5,cea <strchr+0x1a>
  for(; *s; s++)
     ce0:	0505                	addi	a0,a0,1
     ce2:	00054783          	lbu	a5,0(a0)
     ce6:	fbfd                	bnez	a5,cdc <strchr+0xc>
      return (char*)s;
  return 0;
     ce8:	4501                	li	a0,0
}
     cea:	6422                	ld	s0,8(sp)
     cec:	0141                	addi	sp,sp,16
     cee:	8082                	ret
  return 0;
     cf0:	4501                	li	a0,0
     cf2:	bfe5                	j	cea <strchr+0x1a>

0000000000000cf4 <gets>:

char*
gets(char *buf, int max)
{
     cf4:	711d                	addi	sp,sp,-96
     cf6:	ec86                	sd	ra,88(sp)
     cf8:	e8a2                	sd	s0,80(sp)
     cfa:	e4a6                	sd	s1,72(sp)
     cfc:	e0ca                	sd	s2,64(sp)
     cfe:	fc4e                	sd	s3,56(sp)
     d00:	f852                	sd	s4,48(sp)
     d02:	f456                	sd	s5,40(sp)
     d04:	f05a                	sd	s6,32(sp)
     d06:	ec5e                	sd	s7,24(sp)
     d08:	1080                	addi	s0,sp,96
     d0a:	8baa                	mv	s7,a0
     d0c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d0e:	892a                	mv	s2,a0
     d10:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d12:	4aa9                	li	s5,10
     d14:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d16:	89a6                	mv	s3,s1
     d18:	2485                	addiw	s1,s1,1
     d1a:	0344d863          	bge	s1,s4,d4a <gets+0x56>
    cc = read(0, &c, 1);
     d1e:	4605                	li	a2,1
     d20:	faf40593          	addi	a1,s0,-81
     d24:	4501                	li	a0,0
     d26:	00000097          	auipc	ra,0x0
     d2a:	19a080e7          	jalr	410(ra) # ec0 <read>
    if(cc < 1)
     d2e:	00a05e63          	blez	a0,d4a <gets+0x56>
    buf[i++] = c;
     d32:	faf44783          	lbu	a5,-81(s0)
     d36:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d3a:	01578763          	beq	a5,s5,d48 <gets+0x54>
     d3e:	0905                	addi	s2,s2,1
     d40:	fd679be3          	bne	a5,s6,d16 <gets+0x22>
  for(i=0; i+1 < max; ){
     d44:	89a6                	mv	s3,s1
     d46:	a011                	j	d4a <gets+0x56>
     d48:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d4a:	99de                	add	s3,s3,s7
     d4c:	00098023          	sb	zero,0(s3)
  return buf;
}
     d50:	855e                	mv	a0,s7
     d52:	60e6                	ld	ra,88(sp)
     d54:	6446                	ld	s0,80(sp)
     d56:	64a6                	ld	s1,72(sp)
     d58:	6906                	ld	s2,64(sp)
     d5a:	79e2                	ld	s3,56(sp)
     d5c:	7a42                	ld	s4,48(sp)
     d5e:	7aa2                	ld	s5,40(sp)
     d60:	7b02                	ld	s6,32(sp)
     d62:	6be2                	ld	s7,24(sp)
     d64:	6125                	addi	sp,sp,96
     d66:	8082                	ret

0000000000000d68 <stat>:

int
stat(const char *n, struct stat *st)
{
     d68:	1101                	addi	sp,sp,-32
     d6a:	ec06                	sd	ra,24(sp)
     d6c:	e822                	sd	s0,16(sp)
     d6e:	e426                	sd	s1,8(sp)
     d70:	e04a                	sd	s2,0(sp)
     d72:	1000                	addi	s0,sp,32
     d74:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d76:	4581                	li	a1,0
     d78:	00000097          	auipc	ra,0x0
     d7c:	170080e7          	jalr	368(ra) # ee8 <open>
  if(fd < 0)
     d80:	02054563          	bltz	a0,daa <stat+0x42>
     d84:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d86:	85ca                	mv	a1,s2
     d88:	00000097          	auipc	ra,0x0
     d8c:	178080e7          	jalr	376(ra) # f00 <fstat>
     d90:	892a                	mv	s2,a0
  close(fd);
     d92:	8526                	mv	a0,s1
     d94:	00000097          	auipc	ra,0x0
     d98:	13c080e7          	jalr	316(ra) # ed0 <close>
  return r;
}
     d9c:	854a                	mv	a0,s2
     d9e:	60e2                	ld	ra,24(sp)
     da0:	6442                	ld	s0,16(sp)
     da2:	64a2                	ld	s1,8(sp)
     da4:	6902                	ld	s2,0(sp)
     da6:	6105                	addi	sp,sp,32
     da8:	8082                	ret
    return -1;
     daa:	597d                	li	s2,-1
     dac:	bfc5                	j	d9c <stat+0x34>

0000000000000dae <atoi>:

int
atoi(const char *s)
{
     dae:	1141                	addi	sp,sp,-16
     db0:	e422                	sd	s0,8(sp)
     db2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     db4:	00054683          	lbu	a3,0(a0)
     db8:	fd06879b          	addiw	a5,a3,-48
     dbc:	0ff7f793          	zext.b	a5,a5
     dc0:	4625                	li	a2,9
     dc2:	02f66863          	bltu	a2,a5,df2 <atoi+0x44>
     dc6:	872a                	mv	a4,a0
  n = 0;
     dc8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     dca:	0705                	addi	a4,a4,1
     dcc:	0025179b          	slliw	a5,a0,0x2
     dd0:	9fa9                	addw	a5,a5,a0
     dd2:	0017979b          	slliw	a5,a5,0x1
     dd6:	9fb5                	addw	a5,a5,a3
     dd8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     ddc:	00074683          	lbu	a3,0(a4)
     de0:	fd06879b          	addiw	a5,a3,-48
     de4:	0ff7f793          	zext.b	a5,a5
     de8:	fef671e3          	bgeu	a2,a5,dca <atoi+0x1c>
  return n;
}
     dec:	6422                	ld	s0,8(sp)
     dee:	0141                	addi	sp,sp,16
     df0:	8082                	ret
  n = 0;
     df2:	4501                	li	a0,0
     df4:	bfe5                	j	dec <atoi+0x3e>

0000000000000df6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     df6:	1141                	addi	sp,sp,-16
     df8:	e422                	sd	s0,8(sp)
     dfa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     dfc:	02b57463          	bgeu	a0,a1,e24 <memmove+0x2e>
    while(n-- > 0)
     e00:	00c05f63          	blez	a2,e1e <memmove+0x28>
     e04:	1602                	slli	a2,a2,0x20
     e06:	9201                	srli	a2,a2,0x20
     e08:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e0c:	872a                	mv	a4,a0
      *dst++ = *src++;
     e0e:	0585                	addi	a1,a1,1
     e10:	0705                	addi	a4,a4,1
     e12:	fff5c683          	lbu	a3,-1(a1)
     e16:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e1a:	fee79ae3          	bne	a5,a4,e0e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e1e:	6422                	ld	s0,8(sp)
     e20:	0141                	addi	sp,sp,16
     e22:	8082                	ret
    dst += n;
     e24:	00c50733          	add	a4,a0,a2
    src += n;
     e28:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e2a:	fec05ae3          	blez	a2,e1e <memmove+0x28>
     e2e:	fff6079b          	addiw	a5,a2,-1
     e32:	1782                	slli	a5,a5,0x20
     e34:	9381                	srli	a5,a5,0x20
     e36:	fff7c793          	not	a5,a5
     e3a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e3c:	15fd                	addi	a1,a1,-1
     e3e:	177d                	addi	a4,a4,-1
     e40:	0005c683          	lbu	a3,0(a1)
     e44:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e48:	fee79ae3          	bne	a5,a4,e3c <memmove+0x46>
     e4c:	bfc9                	j	e1e <memmove+0x28>

0000000000000e4e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e4e:	1141                	addi	sp,sp,-16
     e50:	e422                	sd	s0,8(sp)
     e52:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e54:	ca05                	beqz	a2,e84 <memcmp+0x36>
     e56:	fff6069b          	addiw	a3,a2,-1
     e5a:	1682                	slli	a3,a3,0x20
     e5c:	9281                	srli	a3,a3,0x20
     e5e:	0685                	addi	a3,a3,1
     e60:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e62:	00054783          	lbu	a5,0(a0)
     e66:	0005c703          	lbu	a4,0(a1)
     e6a:	00e79863          	bne	a5,a4,e7a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e6e:	0505                	addi	a0,a0,1
    p2++;
     e70:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e72:	fed518e3          	bne	a0,a3,e62 <memcmp+0x14>
  }
  return 0;
     e76:	4501                	li	a0,0
     e78:	a019                	j	e7e <memcmp+0x30>
      return *p1 - *p2;
     e7a:	40e7853b          	subw	a0,a5,a4
}
     e7e:	6422                	ld	s0,8(sp)
     e80:	0141                	addi	sp,sp,16
     e82:	8082                	ret
  return 0;
     e84:	4501                	li	a0,0
     e86:	bfe5                	j	e7e <memcmp+0x30>

0000000000000e88 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e88:	1141                	addi	sp,sp,-16
     e8a:	e406                	sd	ra,8(sp)
     e8c:	e022                	sd	s0,0(sp)
     e8e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e90:	00000097          	auipc	ra,0x0
     e94:	f66080e7          	jalr	-154(ra) # df6 <memmove>
}
     e98:	60a2                	ld	ra,8(sp)
     e9a:	6402                	ld	s0,0(sp)
     e9c:	0141                	addi	sp,sp,16
     e9e:	8082                	ret

0000000000000ea0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ea0:	4885                	li	a7,1
 ecall
     ea2:	00000073          	ecall
 ret
     ea6:	8082                	ret

0000000000000ea8 <exit>:
.global exit
exit:
 li a7, SYS_exit
     ea8:	4889                	li	a7,2
 ecall
     eaa:	00000073          	ecall
 ret
     eae:	8082                	ret

0000000000000eb0 <wait>:
.global wait
wait:
 li a7, SYS_wait
     eb0:	488d                	li	a7,3
 ecall
     eb2:	00000073          	ecall
 ret
     eb6:	8082                	ret

0000000000000eb8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     eb8:	4891                	li	a7,4
 ecall
     eba:	00000073          	ecall
 ret
     ebe:	8082                	ret

0000000000000ec0 <read>:
.global read
read:
 li a7, SYS_read
     ec0:	4895                	li	a7,5
 ecall
     ec2:	00000073          	ecall
 ret
     ec6:	8082                	ret

0000000000000ec8 <write>:
.global write
write:
 li a7, SYS_write
     ec8:	48c1                	li	a7,16
 ecall
     eca:	00000073          	ecall
 ret
     ece:	8082                	ret

0000000000000ed0 <close>:
.global close
close:
 li a7, SYS_close
     ed0:	48d5                	li	a7,21
 ecall
     ed2:	00000073          	ecall
 ret
     ed6:	8082                	ret

0000000000000ed8 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ed8:	4899                	li	a7,6
 ecall
     eda:	00000073          	ecall
 ret
     ede:	8082                	ret

0000000000000ee0 <exec>:
.global exec
exec:
 li a7, SYS_exec
     ee0:	489d                	li	a7,7
 ecall
     ee2:	00000073          	ecall
 ret
     ee6:	8082                	ret

0000000000000ee8 <open>:
.global open
open:
 li a7, SYS_open
     ee8:	48bd                	li	a7,15
 ecall
     eea:	00000073          	ecall
 ret
     eee:	8082                	ret

0000000000000ef0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ef0:	48c5                	li	a7,17
 ecall
     ef2:	00000073          	ecall
 ret
     ef6:	8082                	ret

0000000000000ef8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ef8:	48c9                	li	a7,18
 ecall
     efa:	00000073          	ecall
 ret
     efe:	8082                	ret

0000000000000f00 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f00:	48a1                	li	a7,8
 ecall
     f02:	00000073          	ecall
 ret
     f06:	8082                	ret

0000000000000f08 <link>:
.global link
link:
 li a7, SYS_link
     f08:	48cd                	li	a7,19
 ecall
     f0a:	00000073          	ecall
 ret
     f0e:	8082                	ret

0000000000000f10 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f10:	48d1                	li	a7,20
 ecall
     f12:	00000073          	ecall
 ret
     f16:	8082                	ret

0000000000000f18 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f18:	48a5                	li	a7,9
 ecall
     f1a:	00000073          	ecall
 ret
     f1e:	8082                	ret

0000000000000f20 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f20:	48a9                	li	a7,10
 ecall
     f22:	00000073          	ecall
 ret
     f26:	8082                	ret

0000000000000f28 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f28:	48ad                	li	a7,11
 ecall
     f2a:	00000073          	ecall
 ret
     f2e:	8082                	ret

0000000000000f30 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f30:	48b1                	li	a7,12
 ecall
     f32:	00000073          	ecall
 ret
     f36:	8082                	ret

0000000000000f38 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f38:	48b5                	li	a7,13
 ecall
     f3a:	00000073          	ecall
 ret
     f3e:	8082                	ret

0000000000000f40 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f40:	48b9                	li	a7,14
 ecall
     f42:	00000073          	ecall
 ret
     f46:	8082                	ret

0000000000000f48 <ps>:
.global ps
ps:
 li a7, SYS_ps
     f48:	48d9                	li	a7,22
 ecall
     f4a:	00000073          	ecall
 ret
     f4e:	8082                	ret

0000000000000f50 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
     f50:	48dd                	li	a7,23
 ecall
     f52:	00000073          	ecall
 ret
     f56:	8082                	ret

0000000000000f58 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
     f58:	48e1                	li	a7,24
 ecall
     f5a:	00000073          	ecall
 ret
     f5e:	8082                	ret

0000000000000f60 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
     f60:	48e9                	li	a7,26
 ecall
     f62:	00000073          	ecall
 ret
     f66:	8082                	ret

0000000000000f68 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
     f68:	48e5                	li	a7,25
 ecall
     f6a:	00000073          	ecall
 ret
     f6e:	8082                	ret

0000000000000f70 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f70:	1101                	addi	sp,sp,-32
     f72:	ec06                	sd	ra,24(sp)
     f74:	e822                	sd	s0,16(sp)
     f76:	1000                	addi	s0,sp,32
     f78:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f7c:	4605                	li	a2,1
     f7e:	fef40593          	addi	a1,s0,-17
     f82:	00000097          	auipc	ra,0x0
     f86:	f46080e7          	jalr	-186(ra) # ec8 <write>
}
     f8a:	60e2                	ld	ra,24(sp)
     f8c:	6442                	ld	s0,16(sp)
     f8e:	6105                	addi	sp,sp,32
     f90:	8082                	ret

0000000000000f92 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f92:	7139                	addi	sp,sp,-64
     f94:	fc06                	sd	ra,56(sp)
     f96:	f822                	sd	s0,48(sp)
     f98:	f426                	sd	s1,40(sp)
     f9a:	f04a                	sd	s2,32(sp)
     f9c:	ec4e                	sd	s3,24(sp)
     f9e:	0080                	addi	s0,sp,64
     fa0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fa2:	c299                	beqz	a3,fa8 <printint+0x16>
     fa4:	0805c963          	bltz	a1,1036 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     fa8:	2581                	sext.w	a1,a1
  neg = 0;
     faa:	4881                	li	a7,0
     fac:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fb0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fb2:	2601                	sext.w	a2,a2
     fb4:	00000517          	auipc	a0,0x0
     fb8:	5f450513          	addi	a0,a0,1524 # 15a8 <digits>
     fbc:	883a                	mv	a6,a4
     fbe:	2705                	addiw	a4,a4,1
     fc0:	02c5f7bb          	remuw	a5,a1,a2
     fc4:	1782                	slli	a5,a5,0x20
     fc6:	9381                	srli	a5,a5,0x20
     fc8:	97aa                	add	a5,a5,a0
     fca:	0007c783          	lbu	a5,0(a5)
     fce:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fd2:	0005879b          	sext.w	a5,a1
     fd6:	02c5d5bb          	divuw	a1,a1,a2
     fda:	0685                	addi	a3,a3,1
     fdc:	fec7f0e3          	bgeu	a5,a2,fbc <printint+0x2a>
  if(neg)
     fe0:	00088c63          	beqz	a7,ff8 <printint+0x66>
    buf[i++] = '-';
     fe4:	fd070793          	addi	a5,a4,-48
     fe8:	00878733          	add	a4,a5,s0
     fec:	02d00793          	li	a5,45
     ff0:	fef70823          	sb	a5,-16(a4)
     ff4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     ff8:	02e05863          	blez	a4,1028 <printint+0x96>
     ffc:	fc040793          	addi	a5,s0,-64
    1000:	00e78933          	add	s2,a5,a4
    1004:	fff78993          	addi	s3,a5,-1
    1008:	99ba                	add	s3,s3,a4
    100a:	377d                	addiw	a4,a4,-1
    100c:	1702                	slli	a4,a4,0x20
    100e:	9301                	srli	a4,a4,0x20
    1010:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1014:	fff94583          	lbu	a1,-1(s2)
    1018:	8526                	mv	a0,s1
    101a:	00000097          	auipc	ra,0x0
    101e:	f56080e7          	jalr	-170(ra) # f70 <putc>
  while(--i >= 0)
    1022:	197d                	addi	s2,s2,-1
    1024:	ff3918e3          	bne	s2,s3,1014 <printint+0x82>
}
    1028:	70e2                	ld	ra,56(sp)
    102a:	7442                	ld	s0,48(sp)
    102c:	74a2                	ld	s1,40(sp)
    102e:	7902                	ld	s2,32(sp)
    1030:	69e2                	ld	s3,24(sp)
    1032:	6121                	addi	sp,sp,64
    1034:	8082                	ret
    x = -xx;
    1036:	40b005bb          	negw	a1,a1
    neg = 1;
    103a:	4885                	li	a7,1
    x = -xx;
    103c:	bf85                	j	fac <printint+0x1a>

000000000000103e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    103e:	7119                	addi	sp,sp,-128
    1040:	fc86                	sd	ra,120(sp)
    1042:	f8a2                	sd	s0,112(sp)
    1044:	f4a6                	sd	s1,104(sp)
    1046:	f0ca                	sd	s2,96(sp)
    1048:	ecce                	sd	s3,88(sp)
    104a:	e8d2                	sd	s4,80(sp)
    104c:	e4d6                	sd	s5,72(sp)
    104e:	e0da                	sd	s6,64(sp)
    1050:	fc5e                	sd	s7,56(sp)
    1052:	f862                	sd	s8,48(sp)
    1054:	f466                	sd	s9,40(sp)
    1056:	f06a                	sd	s10,32(sp)
    1058:	ec6e                	sd	s11,24(sp)
    105a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    105c:	0005c903          	lbu	s2,0(a1)
    1060:	18090f63          	beqz	s2,11fe <vprintf+0x1c0>
    1064:	8aaa                	mv	s5,a0
    1066:	8b32                	mv	s6,a2
    1068:	00158493          	addi	s1,a1,1
  state = 0;
    106c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    106e:	02500a13          	li	s4,37
    1072:	4c55                	li	s8,21
    1074:	00000c97          	auipc	s9,0x0
    1078:	4dcc8c93          	addi	s9,s9,1244 # 1550 <malloc+0x24e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    107c:	02800d93          	li	s11,40
  putc(fd, 'x');
    1080:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1082:	00000b97          	auipc	s7,0x0
    1086:	526b8b93          	addi	s7,s7,1318 # 15a8 <digits>
    108a:	a839                	j	10a8 <vprintf+0x6a>
        putc(fd, c);
    108c:	85ca                	mv	a1,s2
    108e:	8556                	mv	a0,s5
    1090:	00000097          	auipc	ra,0x0
    1094:	ee0080e7          	jalr	-288(ra) # f70 <putc>
    1098:	a019                	j	109e <vprintf+0x60>
    } else if(state == '%'){
    109a:	01498d63          	beq	s3,s4,10b4 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
    109e:	0485                	addi	s1,s1,1
    10a0:	fff4c903          	lbu	s2,-1(s1)
    10a4:	14090d63          	beqz	s2,11fe <vprintf+0x1c0>
    if(state == 0){
    10a8:	fe0999e3          	bnez	s3,109a <vprintf+0x5c>
      if(c == '%'){
    10ac:	ff4910e3          	bne	s2,s4,108c <vprintf+0x4e>
        state = '%';
    10b0:	89d2                	mv	s3,s4
    10b2:	b7f5                	j	109e <vprintf+0x60>
      if(c == 'd'){
    10b4:	11490c63          	beq	s2,s4,11cc <vprintf+0x18e>
    10b8:	f9d9079b          	addiw	a5,s2,-99
    10bc:	0ff7f793          	zext.b	a5,a5
    10c0:	10fc6e63          	bltu	s8,a5,11dc <vprintf+0x19e>
    10c4:	f9d9079b          	addiw	a5,s2,-99
    10c8:	0ff7f713          	zext.b	a4,a5
    10cc:	10ec6863          	bltu	s8,a4,11dc <vprintf+0x19e>
    10d0:	00271793          	slli	a5,a4,0x2
    10d4:	97e6                	add	a5,a5,s9
    10d6:	439c                	lw	a5,0(a5)
    10d8:	97e6                	add	a5,a5,s9
    10da:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    10dc:	008b0913          	addi	s2,s6,8
    10e0:	4685                	li	a3,1
    10e2:	4629                	li	a2,10
    10e4:	000b2583          	lw	a1,0(s6)
    10e8:	8556                	mv	a0,s5
    10ea:	00000097          	auipc	ra,0x0
    10ee:	ea8080e7          	jalr	-344(ra) # f92 <printint>
    10f2:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    10f4:	4981                	li	s3,0
    10f6:	b765                	j	109e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10f8:	008b0913          	addi	s2,s6,8
    10fc:	4681                	li	a3,0
    10fe:	4629                	li	a2,10
    1100:	000b2583          	lw	a1,0(s6)
    1104:	8556                	mv	a0,s5
    1106:	00000097          	auipc	ra,0x0
    110a:	e8c080e7          	jalr	-372(ra) # f92 <printint>
    110e:	8b4a                	mv	s6,s2
      state = 0;
    1110:	4981                	li	s3,0
    1112:	b771                	j	109e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1114:	008b0913          	addi	s2,s6,8
    1118:	4681                	li	a3,0
    111a:	866a                	mv	a2,s10
    111c:	000b2583          	lw	a1,0(s6)
    1120:	8556                	mv	a0,s5
    1122:	00000097          	auipc	ra,0x0
    1126:	e70080e7          	jalr	-400(ra) # f92 <printint>
    112a:	8b4a                	mv	s6,s2
      state = 0;
    112c:	4981                	li	s3,0
    112e:	bf85                	j	109e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1130:	008b0793          	addi	a5,s6,8
    1134:	f8f43423          	sd	a5,-120(s0)
    1138:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    113c:	03000593          	li	a1,48
    1140:	8556                	mv	a0,s5
    1142:	00000097          	auipc	ra,0x0
    1146:	e2e080e7          	jalr	-466(ra) # f70 <putc>
  putc(fd, 'x');
    114a:	07800593          	li	a1,120
    114e:	8556                	mv	a0,s5
    1150:	00000097          	auipc	ra,0x0
    1154:	e20080e7          	jalr	-480(ra) # f70 <putc>
    1158:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    115a:	03c9d793          	srli	a5,s3,0x3c
    115e:	97de                	add	a5,a5,s7
    1160:	0007c583          	lbu	a1,0(a5)
    1164:	8556                	mv	a0,s5
    1166:	00000097          	auipc	ra,0x0
    116a:	e0a080e7          	jalr	-502(ra) # f70 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    116e:	0992                	slli	s3,s3,0x4
    1170:	397d                	addiw	s2,s2,-1
    1172:	fe0914e3          	bnez	s2,115a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
    1176:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    117a:	4981                	li	s3,0
    117c:	b70d                	j	109e <vprintf+0x60>
        s = va_arg(ap, char*);
    117e:	008b0913          	addi	s2,s6,8
    1182:	000b3983          	ld	s3,0(s6)
        if(s == 0)
    1186:	02098163          	beqz	s3,11a8 <vprintf+0x16a>
        while(*s != 0){
    118a:	0009c583          	lbu	a1,0(s3)
    118e:	c5ad                	beqz	a1,11f8 <vprintf+0x1ba>
          putc(fd, *s);
    1190:	8556                	mv	a0,s5
    1192:	00000097          	auipc	ra,0x0
    1196:	dde080e7          	jalr	-546(ra) # f70 <putc>
          s++;
    119a:	0985                	addi	s3,s3,1
        while(*s != 0){
    119c:	0009c583          	lbu	a1,0(s3)
    11a0:	f9e5                	bnez	a1,1190 <vprintf+0x152>
        s = va_arg(ap, char*);
    11a2:	8b4a                	mv	s6,s2
      state = 0;
    11a4:	4981                	li	s3,0
    11a6:	bde5                	j	109e <vprintf+0x60>
          s = "(null)";
    11a8:	00000997          	auipc	s3,0x0
    11ac:	3a098993          	addi	s3,s3,928 # 1548 <malloc+0x246>
        while(*s != 0){
    11b0:	85ee                	mv	a1,s11
    11b2:	bff9                	j	1190 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
    11b4:	008b0913          	addi	s2,s6,8
    11b8:	000b4583          	lbu	a1,0(s6)
    11bc:	8556                	mv	a0,s5
    11be:	00000097          	auipc	ra,0x0
    11c2:	db2080e7          	jalr	-590(ra) # f70 <putc>
    11c6:	8b4a                	mv	s6,s2
      state = 0;
    11c8:	4981                	li	s3,0
    11ca:	bdd1                	j	109e <vprintf+0x60>
        putc(fd, c);
    11cc:	85d2                	mv	a1,s4
    11ce:	8556                	mv	a0,s5
    11d0:	00000097          	auipc	ra,0x0
    11d4:	da0080e7          	jalr	-608(ra) # f70 <putc>
      state = 0;
    11d8:	4981                	li	s3,0
    11da:	b5d1                	j	109e <vprintf+0x60>
        putc(fd, '%');
    11dc:	85d2                	mv	a1,s4
    11de:	8556                	mv	a0,s5
    11e0:	00000097          	auipc	ra,0x0
    11e4:	d90080e7          	jalr	-624(ra) # f70 <putc>
        putc(fd, c);
    11e8:	85ca                	mv	a1,s2
    11ea:	8556                	mv	a0,s5
    11ec:	00000097          	auipc	ra,0x0
    11f0:	d84080e7          	jalr	-636(ra) # f70 <putc>
      state = 0;
    11f4:	4981                	li	s3,0
    11f6:	b565                	j	109e <vprintf+0x60>
        s = va_arg(ap, char*);
    11f8:	8b4a                	mv	s6,s2
      state = 0;
    11fa:	4981                	li	s3,0
    11fc:	b54d                	j	109e <vprintf+0x60>
    }
  }
}
    11fe:	70e6                	ld	ra,120(sp)
    1200:	7446                	ld	s0,112(sp)
    1202:	74a6                	ld	s1,104(sp)
    1204:	7906                	ld	s2,96(sp)
    1206:	69e6                	ld	s3,88(sp)
    1208:	6a46                	ld	s4,80(sp)
    120a:	6aa6                	ld	s5,72(sp)
    120c:	6b06                	ld	s6,64(sp)
    120e:	7be2                	ld	s7,56(sp)
    1210:	7c42                	ld	s8,48(sp)
    1212:	7ca2                	ld	s9,40(sp)
    1214:	7d02                	ld	s10,32(sp)
    1216:	6de2                	ld	s11,24(sp)
    1218:	6109                	addi	sp,sp,128
    121a:	8082                	ret

000000000000121c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    121c:	715d                	addi	sp,sp,-80
    121e:	ec06                	sd	ra,24(sp)
    1220:	e822                	sd	s0,16(sp)
    1222:	1000                	addi	s0,sp,32
    1224:	e010                	sd	a2,0(s0)
    1226:	e414                	sd	a3,8(s0)
    1228:	e818                	sd	a4,16(s0)
    122a:	ec1c                	sd	a5,24(s0)
    122c:	03043023          	sd	a6,32(s0)
    1230:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1234:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1238:	8622                	mv	a2,s0
    123a:	00000097          	auipc	ra,0x0
    123e:	e04080e7          	jalr	-508(ra) # 103e <vprintf>
}
    1242:	60e2                	ld	ra,24(sp)
    1244:	6442                	ld	s0,16(sp)
    1246:	6161                	addi	sp,sp,80
    1248:	8082                	ret

000000000000124a <printf>:

void
printf(const char *fmt, ...)
{
    124a:	711d                	addi	sp,sp,-96
    124c:	ec06                	sd	ra,24(sp)
    124e:	e822                	sd	s0,16(sp)
    1250:	1000                	addi	s0,sp,32
    1252:	e40c                	sd	a1,8(s0)
    1254:	e810                	sd	a2,16(s0)
    1256:	ec14                	sd	a3,24(s0)
    1258:	f018                	sd	a4,32(s0)
    125a:	f41c                	sd	a5,40(s0)
    125c:	03043823          	sd	a6,48(s0)
    1260:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1264:	00840613          	addi	a2,s0,8
    1268:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    126c:	85aa                	mv	a1,a0
    126e:	4505                	li	a0,1
    1270:	00000097          	auipc	ra,0x0
    1274:	dce080e7          	jalr	-562(ra) # 103e <vprintf>
}
    1278:	60e2                	ld	ra,24(sp)
    127a:	6442                	ld	s0,16(sp)
    127c:	6125                	addi	sp,sp,96
    127e:	8082                	ret

0000000000001280 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1280:	1141                	addi	sp,sp,-16
    1282:	e422                	sd	s0,8(sp)
    1284:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1286:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    128a:	00001797          	auipc	a5,0x1
    128e:	d867b783          	ld	a5,-634(a5) # 2010 <freep>
    1292:	a02d                	j	12bc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1294:	4618                	lw	a4,8(a2)
    1296:	9f2d                	addw	a4,a4,a1
    1298:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    129c:	6398                	ld	a4,0(a5)
    129e:	6310                	ld	a2,0(a4)
    12a0:	a83d                	j	12de <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12a2:	ff852703          	lw	a4,-8(a0)
    12a6:	9f31                	addw	a4,a4,a2
    12a8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    12aa:	ff053683          	ld	a3,-16(a0)
    12ae:	a091                	j	12f2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12b0:	6398                	ld	a4,0(a5)
    12b2:	00e7e463          	bltu	a5,a4,12ba <free+0x3a>
    12b6:	00e6ea63          	bltu	a3,a4,12ca <free+0x4a>
{
    12ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12bc:	fed7fae3          	bgeu	a5,a3,12b0 <free+0x30>
    12c0:	6398                	ld	a4,0(a5)
    12c2:	00e6e463          	bltu	a3,a4,12ca <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12c6:	fee7eae3          	bltu	a5,a4,12ba <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    12ca:	ff852583          	lw	a1,-8(a0)
    12ce:	6390                	ld	a2,0(a5)
    12d0:	02059813          	slli	a6,a1,0x20
    12d4:	01c85713          	srli	a4,a6,0x1c
    12d8:	9736                	add	a4,a4,a3
    12da:	fae60de3          	beq	a2,a4,1294 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    12de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12e2:	4790                	lw	a2,8(a5)
    12e4:	02061593          	slli	a1,a2,0x20
    12e8:	01c5d713          	srli	a4,a1,0x1c
    12ec:	973e                	add	a4,a4,a5
    12ee:	fae68ae3          	beq	a3,a4,12a2 <free+0x22>
    p->s.ptr = bp->s.ptr;
    12f2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    12f4:	00001717          	auipc	a4,0x1
    12f8:	d0f73e23          	sd	a5,-740(a4) # 2010 <freep>
}
    12fc:	6422                	ld	s0,8(sp)
    12fe:	0141                	addi	sp,sp,16
    1300:	8082                	ret

0000000000001302 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1302:	7139                	addi	sp,sp,-64
    1304:	fc06                	sd	ra,56(sp)
    1306:	f822                	sd	s0,48(sp)
    1308:	f426                	sd	s1,40(sp)
    130a:	f04a                	sd	s2,32(sp)
    130c:	ec4e                	sd	s3,24(sp)
    130e:	e852                	sd	s4,16(sp)
    1310:	e456                	sd	s5,8(sp)
    1312:	e05a                	sd	s6,0(sp)
    1314:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1316:	02051493          	slli	s1,a0,0x20
    131a:	9081                	srli	s1,s1,0x20
    131c:	04bd                	addi	s1,s1,15
    131e:	8091                	srli	s1,s1,0x4
    1320:	0014899b          	addiw	s3,s1,1
    1324:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1326:	00001517          	auipc	a0,0x1
    132a:	cea53503          	ld	a0,-790(a0) # 2010 <freep>
    132e:	c515                	beqz	a0,135a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1330:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1332:	4798                	lw	a4,8(a5)
    1334:	02977f63          	bgeu	a4,s1,1372 <malloc+0x70>
    1338:	8a4e                	mv	s4,s3
    133a:	0009871b          	sext.w	a4,s3
    133e:	6685                	lui	a3,0x1
    1340:	00d77363          	bgeu	a4,a3,1346 <malloc+0x44>
    1344:	6a05                	lui	s4,0x1
    1346:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    134a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    134e:	00001917          	auipc	s2,0x1
    1352:	cc290913          	addi	s2,s2,-830 # 2010 <freep>
  if(p == (char*)-1)
    1356:	5afd                	li	s5,-1
    1358:	a895                	j	13cc <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    135a:	00001797          	auipc	a5,0x1
    135e:	d3e78793          	addi	a5,a5,-706 # 2098 <base>
    1362:	00001717          	auipc	a4,0x1
    1366:	caf73723          	sd	a5,-850(a4) # 2010 <freep>
    136a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    136c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1370:	b7e1                	j	1338 <malloc+0x36>
      if(p->s.size == nunits)
    1372:	02e48c63          	beq	s1,a4,13aa <malloc+0xa8>
        p->s.size -= nunits;
    1376:	4137073b          	subw	a4,a4,s3
    137a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    137c:	02071693          	slli	a3,a4,0x20
    1380:	01c6d713          	srli	a4,a3,0x1c
    1384:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1386:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    138a:	00001717          	auipc	a4,0x1
    138e:	c8a73323          	sd	a0,-890(a4) # 2010 <freep>
      return (void*)(p + 1);
    1392:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1396:	70e2                	ld	ra,56(sp)
    1398:	7442                	ld	s0,48(sp)
    139a:	74a2                	ld	s1,40(sp)
    139c:	7902                	ld	s2,32(sp)
    139e:	69e2                	ld	s3,24(sp)
    13a0:	6a42                	ld	s4,16(sp)
    13a2:	6aa2                	ld	s5,8(sp)
    13a4:	6b02                	ld	s6,0(sp)
    13a6:	6121                	addi	sp,sp,64
    13a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13aa:	6398                	ld	a4,0(a5)
    13ac:	e118                	sd	a4,0(a0)
    13ae:	bff1                	j	138a <malloc+0x88>
  hp->s.size = nu;
    13b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13b4:	0541                	addi	a0,a0,16
    13b6:	00000097          	auipc	ra,0x0
    13ba:	eca080e7          	jalr	-310(ra) # 1280 <free>
  return freep;
    13be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13c2:	d971                	beqz	a0,1396 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13c6:	4798                	lw	a4,8(a5)
    13c8:	fa9775e3          	bgeu	a4,s1,1372 <malloc+0x70>
    if(p == freep)
    13cc:	00093703          	ld	a4,0(s2)
    13d0:	853e                	mv	a0,a5
    13d2:	fef719e3          	bne	a4,a5,13c4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    13d6:	8552                	mv	a0,s4
    13d8:	00000097          	auipc	ra,0x0
    13dc:	b58080e7          	jalr	-1192(ra) # f30 <sbrk>
  if(p == (char*)-1)
    13e0:	fd5518e3          	bne	a0,s5,13b0 <malloc+0xae>
        return 0;
    13e4:	4501                	li	a0,0
    13e6:	bf45                	j	1396 <malloc+0x94>
