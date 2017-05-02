<?php

namespace Razorpay\IFSC;

class Bank
{
    const AACX = 'AACX';
    const ABCX = 'ABCX';
    const ABDX = 'ABDX';
    const ABEX = 'ABEX';
    const ABHY = 'ABHY';
    const ABNA = 'ABNA';
    const ABSB = 'ABSB';
    const ABUX = 'ABUX';
    const ACAX = 'ACAX';
    const ACBX = 'ACBX';
    const ACCX = 'ACCX';
    const ACKX = 'ACKX';
    const ACOX = 'ACOX';
    const ACUB = 'ACUB';
    const ACUX = 'ACUX';
    const ADBX = 'ADBX';
    const ADCB = 'ADCB';
    const ADCC = 'ADCC';
    const ADCX = 'ADCX';
    const ADDX = 'ADDX';
    const AGCX = 'AGCX';
    const AGDX = 'AGDX';
    const AGRX = 'AGRX';
    const AGSX = 'AGSX';
    const AGUX = 'AGUX';
    const AGVX = 'AGVX';
    const AHMX = 'AHMX';
    const AHUX = 'AHUX';
    const AIRP = 'AIRP';
    const AJKB = 'AJKB';
    const AJMX = 'AJMX';
    const AJNX = 'AJNX';
    const AJPX = 'AJPX';
    const AJSX = 'AJSX';
    const AJUX = 'AJUX';
    const AKJB = 'AKJB';
    const AKMX = 'AKMX';
    const AKOX = 'AKOX';
    const ALAX = 'ALAX';
    const ALIX = 'ALIX';
    const ALLA = 'ALLA';
    const ALLX = 'ALLX';
    const ALWX = 'ALWX';
    const AMAX = 'AMAX';
    const AMBX = 'AMBX';
    const AMCB = 'AMCB';
    const AMCX = 'AMCX';
    const AMMX = 'AMMX';
    const AMNX = 'AMNX';
    const AMRX = 'AMRX';
    const AMSX = 'AMSX';
    const ANBX = 'ANBX';
    const ANDB = 'ANDB';
    const ANDX = 'ANDX';
    const ANMX = 'ANMX';
    const ANSX = 'ANSX';
    const ANUX = 'ANUX';
    const ANZB = 'ANZB';
    const APBL = 'APBL';
    const APCX = 'APCX';
    const APGB = 'APGB';
    const APGX = 'APGX';
    const APJX = 'APJX';
    const APMC = 'APMC';
    const APMX = 'APMX';
    const APNX = 'APNX';
    const APRX = 'APRX';
    const APSX = 'APSX';
    const ARCX = 'ARCX';
    const ARMX = 'ARMX';
    const ARYX = 'ARYX';
    const ASBL = 'ASBL';
    const ASBX = 'ASBX';
    const ASHX = 'ASHX';
    const ASKX = 'ASKX';
    const ASOX = 'ASOX';
    const ASSX = 'ASSX';
    const AUBX = 'AUBX';
    const AUCB = 'AUCB';
    const AUCX = 'AUCX';
    const AUGX = 'AUGX';
    const AURX = 'AURX';
    const AVDX = 'AVDX';
    const AWCX = 'AWCX';
    const AWUX = 'AWUX';
    const AZAX = 'AZAX';
    const AZPX = 'AZPX';
    const AZSX = 'AZSX';
    const AZUX = 'AZUX';
    const BACB = 'BACB';
    const BACX = 'BACX';
    const BADX = 'BADX';
    const BALX = 'BALX';
    const BANX = 'BANX';
    const BARA = 'BARA';
    const BARB = 'BARB';
    const BARC = 'BARC';
    const BARX = 'BARX';
    const BASX = 'BASX';
    const BAUX = 'BAUX';
    const BAVX = 'BAVX';
    const BBKM = 'BBKM';
    const BBLX = 'BBLX';
    const BBRX = 'BBRX';
    const BBSX = 'BBSX';
    const BBUX = 'BBUX';
    const BBVX = 'BBVX';
    const BCBM = 'BCBM';
    const BCBX = 'BCBX';
    const BCCB = 'BCCB';
    const BCCX = 'BCCX';
    const BCEX = 'BCEX';
    const BCEY = 'BCEY';
    const BCUB = 'BCUB';
    const BCUX = 'BCUX';
    const BDBL = 'BDBL';
    const BDBX = 'BDBX';
    const BDCX = 'BDCX';
    const BDDX = 'BDDX';
    const BDIX = 'BDIX';
    const BDNX = 'BDNX';
    const BDOX = 'BDOX';
    const BDUX = 'BDUX';
    const BEDX = 'BEDX';
    const BELX = 'BELX';
    const BFUX = 'BFUX';
    const BGBX = 'BGBX';
    const BGCX = 'BGCX';
    const BGGX = 'BGGX';
    const BGUX = 'BGUX';
    const BGVX = 'BGVX';
    const BHAX = 'BHAX';
    const BHBX = 'BHBX';
    const BHCX = 'BHCX';
    const BHDX = 'BHDX';
    const BHEX = 'BHEX';
    const BHGX = 'BHGX';
    const BHIX = 'BHIX';
    const BHJX = 'BHJX';
    const BHMX = 'BHMX';
    const BHOX = 'BHOX';
    const BHRX = 'BHRX';
    const BHSX = 'BHSX';
    const BHTX = 'BHTX';
    const BHUX = 'BHUX';
    const BHWX = 'BHWX';
    const BJUX = 'BJUX';
    const BKCX = 'BKCX';
    const BKDN = 'BKDN';
    const BKDX = 'BKDX';
    const BKID = 'BKID';
    const BKSX = 'BKSX';
    const BLGX = 'BLGX';
    const BMBL = 'BMBL';
    const BMCB = 'BMCB';
    const BMCX = 'BMCX';
    const BMPX = 'BMPX';
    const BMSX = 'BMSX';
    const BNBX = 'BNBX';
    const BNCX = 'BNCX';
    const BNPA = 'BNPA';
    const BNSX = 'BNSX';
    const BODX = 'BODX';
    const BOFA = 'BOFA';
    const BORX = 'BORX';
    const BOTM = 'BOTM';
    const BOTX = 'BOTX';
    const BPCX = 'BPCX';
    const BPSX = 'BPSX';
    const BRCX = 'BRCX';
    const BRDX = 'BRDX';
    const BRGX = 'BRGX';
    const BRMX = 'BRMX';
    const BRSX = 'BRSX';
    const BRUX = 'BRUX';
    const BSBX = 'BSBX';
    const BSCX = 'BSCX';
    const BTCX = 'BTCX';
    const BTUX = 'BTUX';
    const BUBX = 'BUBX';
    const BUCX = 'BUCX';
    const BUGX = 'BUGX';
    const BUNX = 'BUNX';
    const BURX = 'BURX';
    const BUSX = 'BUSX';
    const BUZX = 'BUZX';
    const BVNX = 'BVNX';
    const BVSX = 'BVSX';
    const BWCX = 'BWCX';
    const CALX = 'CALX';
    const CBHX = 'CBHX';
    const CBIN = 'CBIN';
    const CCBL = 'CCBL';
    const CCBX = 'CCBX';
    const CCCX = 'CCCX';
    const CCMX = 'CCMX';
    const CCOB = 'CCOB';
    const CCUX = 'CCUX';
    const CDCX = 'CDCX';
    const CEBX = 'CEBX';
    const CGBX = 'CGBX';
    const CGGX = 'CGGX';
    const CHAS = 'CHAS';
    const CHAX = 'CHAX';
    const CHBX = 'CHBX';
    const CHCX = 'CHCX';
    const CHDX = 'CHDX';
    const CHIX = 'CHIX';
    const CHKX = 'CHKX';
    const CHPX = 'CHPX';
    const CHRX = 'CHRX';
    const CHSX = 'CHSX';
    const CHTX = 'CHTX';
    const CIDX = 'CIDX';
    const CITI = 'CITI';
    const CITX = 'CITX';
    const CIUB = 'CIUB';
    const CJAX = 'CJAX';
    const CJMX = 'CJMX';
    const CLBL = 'CLBL';
    const CMCB = 'CMCB';
    const CMCX = 'CMCX';
    const CMDX = 'CMDX';
    const CMLX = 'CMLX';
    const CMPX = 'CMPX';
    const CNRB = 'CNRB';
    const CNSX = 'CNSX';
    const COCX = 'COCX';
    const COLX = 'COLX';
    const COMX = 'COMX';
    const CONX = 'CONX';
    const CORP = 'CORP';
    const COSB = 'COSB';
    const CPDX = 'CPDX';
    const CRBX = 'CRBX';
    const CRES = 'CRES';
    const CRLY = 'CRLY';
    const CRSX = 'CRSX';
    const CRUB = 'CRUB';
    const CSBK = 'CSBK';
    const CSBX = 'CSBX';
    const CTBA = 'CTBA';
    const CTBX = 'CTBX';
    const CTCB = 'CTCB';
    const CTOX = 'CTOX';
    const CTUX = 'CTUX';
    const CUBX = 'CUBX';
    const CUCX = 'CUCX';
    const CURX = 'CURX';
    const CZCX = 'CZCX';
    const CZUX = 'CZUX';
    const DAAX = 'DAAX';
    const DAHX = 'DAHX';
    const DAUX = 'DAUX';
    const DBAX = 'DBAX';
    const DBSS = 'DBSS';
    const DCBL = 'DCBL';
    const DCBX = 'DCBX';
    const DCCX = 'DCCX';
    const DCDX = 'DCDX';
    const DCEX = 'DCEX';
    const DCKX = 'DCKX';
    const DCMX = 'DCMX';
    const DCNX = 'DCNX';
    const DCPX = 'DCPX';
    const DCSX = 'DCSX';
    const DCTX = 'DCTX';
    const DCUX = 'DCUX';
    const DDBX = 'DDBX';
    const DDCX = 'DDCX';
    const DDDX = 'DDDX';
    const DDHX = 'DDHX';
    const DEGX = 'DEGX';
    const DENS = 'DENS';
    const DEOB = 'DEOB';
    const DEOX = 'DEOX';
    const DEUT = 'DEUT';
    const DEUX = 'DEUX';
    const DEVX = 'DEVX';
    const DGBX = 'DGBX';
    const DHBX = 'DHBX';
    const DHKX = 'DHKX';
    const DHUX = 'DHUX';
    const DIBX = 'DIBX';
    const DICG = 'DICG';
    const DICX = 'DICX';
    const DIUX = 'DIUX';
    const DJCX = 'DJCX';
    const DKSX = 'DKSX';
    const DLSC = 'DLSC';
    const DLXB = 'DLXB';
    const DMCB = 'DMCB';
    const DMCX = 'DMCX';
    const DMKB = 'DMKB';
    const DNSB = 'DNSB';
    const DNSX = 'DNSX';
    const DOBX = 'DOBX';
    const DOHB = 'DOHB';
    const DRGX = 'DRGX';
    const DSBX = 'DSBX';
    const DSCB = 'DSCB';
    const DSHX = 'DSHX';
    const DSPX = 'DSPX';
    const DSUX = 'DSUX';
    const DTCX = 'DTCX';
    const DTPX = 'DTPX';
    const DUCX = 'DUCX';
    const DUMX = 'DUMX';
    const DUNX = 'DUNX';
    const DVDX = 'DVDX';
    const DYPX = 'DYPX';
    const ECBL = 'ECBL';
    const EDBX = 'EDBX';
    const EDCX = 'EDCX';
    const EDSX = 'EDSX';
    const EIBI = 'EIBI';
    const ESFB = 'ESFB';
    const ESMF = 'ESMF';
    const ETCX = 'ETCX';
    const ETDX = 'ETDX';
    const EUCX = 'EUCX';
    const EWCX = 'EWCX';
    const FCBX = 'FCBX';
    const FCCX = 'FCCX';
    const FDFX = 'FDFX';
    const FDRL = 'FDRL';
    const FEKX = 'FEKX';
    const FGCB = 'FGCB';
    const FINX = 'FINX';
    const FIRN = 'FIRN';
    const FIRX = 'FIRX';
    const FMCX = 'FMCX';
    const FRIX = 'FRIX';
    const FSCX = 'FSCX';
    const FZCX = 'FZCX';
    const FZSX = 'FZSX';
    const GACX = 'GACX';
    const GADX = 'GADX';
    const GANX = 'GANX';
    const GBCB = 'GBCB';
    const GCBX = 'GCBX';
    const GCCX = 'GCCX';
    const GCUL = 'GCUL';
    const GCUX = 'GCUX';
    const GDCB = 'GDCB';
    const GDCX = 'GDCX';
    const GDDX = 'GDDX';
    const GDUX = 'GDUX';
    const GGBK = 'GGBK';
    const GGCX = 'GGCX';
    const GHPX = 'GHPX';
    const GKNX = 'GKNX';
    const GMBX = 'GMBX';
    const GMCX = 'GMCX';
    const GNCX = 'GNCX';
    const GNSX = 'GNSX';
    const GODX = 'GODX';
    const GOSX = 'GOSX';
    const GPCX = 'GPCX';
    const GPOX = 'GPOX';
    const GRAX = 'GRAX';
    const GSBL = 'GSBL';
    const GSBX = 'GSBX';
    const GSCB = 'GSCB';
    const GSCX = 'GSCX';
    const GSSX = 'GSSX';
    const GTCX = 'GTCX';
    const GUBX = 'GUBX';
    const GUCX = 'GUCX';
    const GUNX = 'GUNX';
    const GUOX = 'GUOX';
    const HAMX = 'HAMX';
    const HANX = 'HANX';
    const HCBL = 'HCBL';
    const HCBX = 'HCBX';
    const HCCX = 'HCCX';
    const HCLX = 'HCLX';
    const HDCX = 'HDCX';
    const HDFC = 'HDFC';
    const HGBX = 'HGBX';
    const HINX = 'HINX';
    const HISX = 'HISX';
    const HMBX = 'HMBX';
    const HMNX = 'HMNX';
    const HOCX = 'HOCX';
    const HOOX = 'HOOX';
    const HPCX = 'HPCX';
    const HPSC = 'HPSC';
    const HPSX = 'HPSX';
    const HSBC = 'HSBC';
    const HSBX = 'HSBX';
    const HSCX = 'HSCX';
    const HSDX = 'HSDX';
    const HSSX = 'HSSX';
    const HUBX = 'HUBX';
    const HUCX = 'HUCX';
    const HUTX = 'HUTX';
    const HVBK = 'HVBK';
    const IBBK = 'IBBK';
    const IBKL = 'IBKL';
    const IBKO = 'IBKO';
    const ICBK = 'ICBK';
    const ICBL = 'ICBL';
    const ICHX = 'ICHX';
    const ICIC = 'ICIC';
    const ICMX = 'ICMX';
    const IDFB = 'IDFB';
    const IDIB = 'IDIB';
    const IDUK = 'IDUK';
    const IDUX = 'IDUX';
    const IMPX = 'IMPX';
    const INCX = 'INCX';
    const INDB = 'INDB';
    const INDX = 'INDX';
    const IOBA = 'IOBA';
    const IPCX = 'IPCX';
    const IPSX = 'IPSX';
    const ISBX = 'ISBX';
    const ISMX = 'ISMX';
    const ITCX = 'ITCX';
    const ITDX = 'ITDX';
    const IUCB = 'IUCB';
    const IUCX = 'IUCX';
    const JACX = 'JACX';
    const JAKA = 'JAKA';
    const JALX = 'JALX';
    const JAMX = 'JAMX';
    const JANA = 'JANA';
    const JANX = 'JANX';
    const JASB = 'JASB';
    const JASX = 'JASX';
    const JAUX = 'JAUX';
    const JBHX = 'JBHX';
    const JBIX = 'JBIX';
    const JBMX = 'JBMX';
    const JCBX = 'JCBX';
    const JCCB = 'JCCB';
    const JCCX = 'JCCX';
    const JCDX = 'JCDX';
    const JCHX = 'JCHX';
    const JCPX = 'JCPX';
    const JCUX = 'JCUX';
    const JDCX = 'JDCX';
    const JDEX = 'JDEX';
    const JGBX = 'JGBX';
    const JGCX = 'JGCX';
    const JGWX = 'JGWX';
    const JHAX = 'JHAX';
    const JHSX = 'JHSX';
    const JHUX = 'JHUX';
    const JIBX = 'JIBX';
    const JICX = 'JICX';
    const JIDX = 'JIDX';
    const JIGX = 'JIGX';
    const JIKX = 'JIKX';
    const JIMX = 'JIMX';
    const JINX = 'JINX';
    const JIOX = 'JIOX';
    const JIRX = 'JIRX';
    const JISX = 'JISX';
    const JIVX = 'JIVX';
    const JJCX = 'JJCX';
    const JJHX = 'JJHX';
    const JJSB = 'JJSB';
    const JKAX = 'JKAX';
    const JKCX = 'JKCX';
    const JKDX = 'JKDX';
    const JKEX = 'JKEX';
    const JKHX = 'JKHX';
    const JKMX = 'JKMX';
    const JKRX = 'JKRX';
    const JKSX = 'JKSX';
    const JLCX = 'JLCX';
    const JLDX = 'JLDX';
    const JLNX = 'JLNX';
    const JLSX = 'JLSX';
    const JLWX = 'JLWX';
    const JMAX = 'JMAX';
    const JMBX = 'JMBX';
    const JMCX = 'JMCX';
    const JMDX = 'JMDX';
    const JMHX = 'JMHX';
    const JMMX = 'JMMX';
    const JMOX = 'JMOX';
    const JMPX = 'JMPX';
    const JMSX = 'JMSX';
    const JMYX = 'JMYX';
    const JNAX = 'JNAX';
    const JNDX = 'JNDX';
    const JNSX = 'JNSX';
    const JODX = 'JODX';
    const JONX = 'JONX';
    const JOWX = 'JOWX';
    const JPAX = 'JPAX';
    const JPCB = 'JPCB';
    const JPCX = 'JPCX';
    const JRAX = 'JRAX';
    const JRKX = 'JRKX';
    const JRNX = 'JRNX';
    const JRSX = 'JRSX';
    const JSAB = 'JSAB';
    const JSAX = 'JSAX';
    const JSBL = 'JSBL';
    const JSBP = 'JSBP';
    const JSBX = 'JSBX';
    const JSCX = 'JSCX';
    const JSDX = 'JSDX';
    const JSEX = 'JSEX';
    const JSHX = 'JSHX';
    const JSKX = 'JSKX';
    const JSMX = 'JSMX';
    const JSOX = 'JSOX';
    const JSRX = 'JSRX';
    const JSTX = 'JSTX';
    const JSVX = 'JSVX';
    const JSWX = 'JSWX';
    const JTIX = 'JTIX';
    const JTSX = 'JTSX';
    const JUCX = 'JUCX';
    const JUSX = 'JUSX';
    const JVCX = 'JVCX';
    const KAAX = 'KAAX';
    const KACE = 'KACE';
    const KACX = 'KACX';
    const KADX = 'KADX';
    const KAGX = 'KAGX';
    const KAIJ = 'KAIJ';
    const KALX = 'KALX';
    const KAMX = 'KAMX';
    const KANG = 'KANG';
    const KANX = 'KANX';
    const KARB = 'KARB';
    const KARX = 'KARX';
    const KASX = 'KASX';
    const KATX = 'KATX';
    const KAYX = 'KAYX';
    const KBCX = 'KBCX';
    const KBNX = 'KBNX';
    const KBSX = 'KBSX';
    const KCBL = 'KCBL';
    const KCBX = 'KCBX';
    const KCCB = 'KCCB';
    const KCCX = 'KCCX';
    const KCDX = 'KCDX';
    const KCEX = 'KCEX';
    const KCOB = 'KCOB';
    const KCUB = 'KCUB';
    const KCUX = 'KCUX';
    const KDBX = 'KDBX';
    const KDCX = 'KDCX';
    const KDIX = 'KDIX';
    const KDNX = 'KDNX';
    const KDUX = 'KDUX';
    const KEMX = 'KEMX';
    const KESX = 'KESX';
    const KGBX = 'KGBX';
    const KGDX = 'KGDX';
    const KGSX = 'KGSX';
    const KHAX = 'KHAX';
    const KHCX = 'KHCX';
    const KHDX = 'KHDX';
    const KHNX = 'KHNX';
    const KHUX = 'KHUX';
    const KICX = 'KICX';
    const KJSB = 'KJSB';
    const KJSX = 'KJSX';
    const KKBK = 'KKBK';
    const KKMX = 'KKMX';
    const KKSX = 'KKSX';
    const KLGB = 'KLGB';
    const KLMX = 'KLMX';
    const KMCB = 'KMCB';
    const KMCX = 'KMCX';
    const KMNX = 'KMNX';
    const KMSX = 'KMSX';
    const KNBX = 'KNBX';
    const KNCX = 'KNCX';
    const KNNX = 'KNNX';
    const KNPX = 'KNPX';
    const KNSB = 'KNSB';
    const KNSX = 'KNSX';
    const KOBX = 'KOBX';
    const KOCX = 'KOCX';
    const KODX = 'KODX';
    const KOEX = 'KOEX';
    const KOSX = 'KOSX';
    const KOTX = 'KOTX';
    const KOYX = 'KOYX';
    const KPCX = 'KPCX';
    const KRCX = 'KRCX';
    const KRDX = 'KRDX';
    const KRIX = 'KRIX';
    const KRMX = 'KRMX';
    const KRNX = 'KRNX';
    const KRTX = 'KRTX';
    const KSBX = 'KSBX';
    const KSCB = 'KSCB';
    const KSCX = 'KSCX';
    const KSMX = 'KSMX';
    const KSNX = 'KSNX';
    const KSTX = 'KSTX';
    const KSUX = 'KSUX';
    const KTBX = 'KTBX';
    const KTCX = 'KTCX';
    const KTDX = 'KTDX';
    const KUCB = 'KUCB';
    const KUCX = 'KUCX';
    const KUKX = 'KUKX';
    const KULX = 'KULX';
    const KUMX = 'KUMX';
    const KUNS = 'KUNS';
    const KURX = 'KURX';
    const KVBL = 'KVBL';
    const KVCX = 'KVCX';
    const KVGB = 'KVGB';
    const LACX = 'LACX';
    const LATX = 'LATX';
    const LAVB = 'LAVB';
    const LBMX = 'LBMX';
    const LCBX = 'LCBX';
    const LCCX = 'LCCX';
    const LDCX = 'LDCX';
    const LDPX = 'LDPX';
    const LDRX = 'LDRX';
    const LECX = 'LECX';
    const LICB = 'LICB';
    const LKBL = 'LKBL';
    const LKCX = 'LKCX';
    const LKHX = 'LKHX';
    const LKMX = 'LKMX';
    const LMNX = 'LMNX';
    const LNSX = 'LNSX';
    const LOKX = 'LOKX';
    const LONX = 'LONX';
    const LUCX = 'LUCX';
    const LULX = 'LULX';
    const MABL = 'MABL';
    const MACX = 'MACX';
    const MADX = 'MADX';
    const MAGX = 'MAGX';
    const MAHB = 'MAHB';
    const MAHG = 'MAHG';
    const MAHX = 'MAHX';
    const MAKX = 'MAKX';
    const MALX = 'MALX';
    const MAMX = 'MAMX';
    const MANX = 'MANX';
    const MAPX = 'MAPX';
    const MASX = 'MASX';
    const MAUX = 'MAUX';
    const MAVX = 'MAVX';
    const MAYX = 'MAYX';
    const MBCX = 'MBCX';
    const MBGX = 'MBGX';
    const MBLX = 'MBLX';
    const MCAX = 'MCAX';
    const MCBL = 'MCBL';
    const MCBX = 'MCBX';
    const MCCX = 'MCCX';
    const MCDX = 'MCDX';
    const MCLX = 'MCLX';
    const MCOX = 'MCOX';
    const MCSX = 'MCSX';
    const MCUX = 'MCUX';
    const MDCB = 'MDCB';
    const MDCX = 'MDCX';
    const MDEX = 'MDEX';
    const MDGX = 'MDGX';
    const MDIX = 'MDIX';
    const MDMX = 'MDMX';
    const MDPX = 'MDPX';
    const MEDX = 'MEDX';
    const MERX = 'MERX';
    const MEUX = 'MEUX';
    const MFCX = 'MFCX';
    const MFUX = 'MFUX';
    const MGBX = 'MGBX';
    const MGCB = 'MGCB';
    const MGCX = 'MGCX';
    const MGDX = 'MGDX';
    const MGRB = 'MGRB';
    const MGSX = 'MGSX';
    const MGUX = 'MGUX';
    const MHCB = 'MHCB';
    const MHCX = 'MHCX';
    const MHEX = 'MHEX';
    const MHLX = 'MHLX';
    const MHMX = 'MHMX';
    const MHNX = 'MHNX';
    const MHSX = 'MHSX';
    const MHUX = 'MHUX';
    const MIZX = 'MIZX';
    const MJCX = 'MJCX';
    const MKUX = 'MKUX';
    const MKYX = 'MKYX';
    const MLDX = 'MLDX';
    const MMCX = 'MMCX';
    const MMMX = 'MMMX';
    const MNBX = 'MNBX';
    const MNCX = 'MNCX';
    const MNSX = 'MNSX';
    const MOGX = 'MOGX';
    const MPCX = 'MPCX';
    const MPDX = 'MPDX';
    const MPRX = 'MPRX';
    const MRBX = 'MRBX';
    const MRTX = 'MRTX';
    const MSAX = 'MSAX';
    const MSBL = 'MSBL';
    const MSBX = 'MSBX';
    const MSCI = 'MSCI';
    const MSCX = 'MSCX';
    const MSHQ = 'MSHQ';
    const MSNU = 'MSNU';
    const MSNX = 'MSNX';
    const MSOX = 'MSOX';
    const MSSX = 'MSSX';
    const MUBL = 'MUBL';
    const MUBX = 'MUBX';
    const MUCX = 'MUCX';
    const MUDX = 'MUDX';
    const MUNX = 'MUNX';
    const MUPX = 'MUPX';
    const MURX = 'MURX';
    const MUSX = 'MUSX';
    const MVCX = 'MVCX';
    const MVIX = 'MVIX';
    const MYAX = 'MYAX';
    const MYSX = 'MYSX';
    const MZCX = 'MZCX';
    const MZRX = 'MZRX';
    const NABX = 'NABX';
    const NACX = 'NACX';
    const NAGX = 'NAGX';
    const NAIX = 'NAIX';
    const NALX = 'NALX';
    const NANX = 'NANX';
    const NASX = 'NASX';
    const NATA = 'NATA';
    const NAUX = 'NAUX';
    const NAVX = 'NAVX';
    const NAWX = 'NAWX';
    const NBAD = 'NBAD';
    const NBBX = 'NBBX';
    const NBCX = 'NBCX';
    const NCBL = 'NCBL';
    const NCBX = 'NCBX';
    const NCCX = 'NCCX';
    const NCUX = 'NCUX';
    const NDCX = 'NDCX';
    const NDDX = 'NDDX';
    const NDGX = 'NDGX';
    const NDIX = 'NDIX';
    const NEYX = 'NEYX';
    const NGBX = 'NGBX';
    const NGKX = 'NGKX';
    const NGNX = 'NGNX';
    const NGRX = 'NGRX';
    const NGSB = 'NGSB';
    const NGSX = 'NGSX';
    const NICB = 'NICB';
    const NIDX = 'NIDX';
    const NILX = 'NILX';
    const NIRX = 'NIRX';
    const NIUX = 'NIUX';
    const NJCX = 'NJCX';
    const NJGX = 'NJGX';
    const NJMX = 'NJMX';
    const NJSX = 'NJSX';
    const NKGS = 'NKGS';
    const NLGX = 'NLGX';
    const NLUX = 'NLUX';
    const NMCB = 'NMCB';
    const NMCX = 'NMCX';
    const NMGB = 'NMGB';
    const NNCX = 'NNCX';
    const NNSB = 'NNSB';
    const NNSX = 'NNSX';
    const NOBX = 'NOBX';
    const NOIX = 'NOIX';
    const NOSC = 'NOSC';
    const NPCX = 'NPCX';
    const NPKX = 'NPKX';
    const NRDX = 'NRDX';
    const NSBX = 'NSBX';
    const NSCX = 'NSCX';
    const NSGX = 'NSGX';
    const NSIX = 'NSIX';
    const NSJX = 'NSJX';
    const NSMX = 'NSMX';
    const NSPX = 'NSPX';
    const NSRX = 'NSRX';
    const NTBL = 'NTBL';
    const NUBX = 'NUBX';
    const NUCB = 'NUCB';
    const NUCX = 'NUCX';
    const NVCX = 'NVCX';
    const NVNM = 'NVNM';
    const NVSX = 'NVSX';
    const NWCX = 'NWCX';
    const ODCX = 'ODCX';
    const ODGB = 'ODGB';
    const OIBA = 'OIBA';
    const OMCX = 'OMCX';
    const ONSX = 'ONSX';
    const ORBC = 'ORBC';
    const ORCB = 'ORCB';
    const OSMX = 'OSMX';
    const PABX = 'PABX';
    const PACX = 'PACX';
    const PADX = 'PADX';
    const PALX = 'PALX';
    const PANX = 'PANX';
    const PARX = 'PARX';
    const PASX = 'PASX';
    const PATX = 'PATX';
    const PAYX = 'PAYX';
    const PBGX = 'PBGX';
    const PCBL = 'PCBL';
    const PCBX = 'PCBX';
    const PCCX = 'PCCX';
    const PCLX = 'PCLX';
    const PCMX = 'PCMX';
    const PCOX = 'PCOX';
    const PCPX = 'PCPX';
    const PCSX = 'PCSX';
    const PCTX = 'PCTX';
    const PCUX = 'PCUX';
    const PDBX = 'PDBX';
    const PDCX = 'PDCX';
    const PDNX = 'PDNX';
    const PDSX = 'PDSX';
    const PDUX = 'PDUX';
    const PGBX = 'PGBX';
    const PGCX = 'PGCX';
    const PGRX = 'PGRX';
    const PGTX = 'PGTX';
    const PITX = 'PITX';
    const PJSB = 'PJSB';
    const PKBX = 'PKBX';
    const PKDX = 'PKDX';
    const PKGB = 'PKGB';
    const PLOX = 'PLOX';
    const PLUX = 'PLUX';
    const PMCB = 'PMCB';
    const PMCX = 'PMCX';
    const PMEC = 'PMEC';
    const PMNX = 'PMNX';
    const PNCX = 'PNCX';
    const PNMX = 'PNMX';
    const PNPX = 'PNPX';
    const PNSX = 'PNSX';
    const PPBX = 'PPBX';
    const PPCX = 'PPCX';
    const PRCX = 'PRCX';
    const PREX = 'PREX';
    const PROX = 'PROX';
    const PRPX = 'PRPX';
    const PRSX = 'PRSX';
    const PRTH = 'PRTH';
    const PSBX = 'PSBX';
    const PSCX = 'PSCX';
    const PSIB = 'PSIB';
    const PSRX = 'PSRX';
    const PSSX = 'PSSX';
    const PTCX = 'PTCX';
    const PTNX = 'PTNX';
    const PTSX = 'PTSX';
    const PUBX = 'PUBX';
    const PUCB = 'PUCB';
    const PUCX = 'PUCX';
    const PUDX = 'PUDX';
    const PUGX = 'PUGX';
    const PUNB = 'PUNB';
    const PUNX = 'PUNX';
    const PURX = 'PURX';
    const PUSX = 'PUSX';
    const PUUX = 'PUUX';
    const PVAX = 'PVAX';
    const PVCX = 'PVCX';
    const PVVX = 'PVVX';
    const PWUX = 'PWUX';
    const PYCX = 'PYCX';
    const QUCX = 'QUCX';
    const RABO = 'RABO';
    const RACX = 'RACX';
    const RAEX = 'RAEX';
    const RAJX = 'RAJX';
    const RAKX = 'RAKX';
    const RAMX = 'RAMX';
    const RANX = 'RANX';
    const RATN = 'RATN';
    const RAUX = 'RAUX';
    const RBBX = 'RBBX';
    const RBCX = 'RBCX';
    const RBIS = 'RBIS';
    const RCBX = 'RCBX';
    const RCCX = 'RCCX';
    const RCDX = 'RCDX';
    const RCMX = 'RCMX';
    const RDCX = 'RDCX';
    const RDNX = 'RDNX';
    const REBX = 'REBX';
    const RECX = 'RECX';
    const REWX = 'REWX';
    const RGCX = 'RGCX';
    const RGSX = 'RGSX';
    const RHMX = 'RHMX';
    const RJCX = 'RJCX';
    const RJJX = 'RJJX';
    const RJNX = 'RJNX';
    const RJTX = 'RJTX';
    const RKCX = 'RKCX';
    const RLUX = 'RLUX';
    const RNBX = 'RNBX';
    const RNDX = 'RNDX';
    const RNGX = 'RNGX';
    const RNSB = 'RNSB';
    const RNSX = 'RNSX';
    const ROCX = 'ROCX';
    const ROHX = 'ROHX';
    const RPUX = 'RPUX';
    const RRSX = 'RRSX';
    const RSBL = 'RSBL';
    const RSBX = 'RSBX';
    const RSCB = 'RSCB';
    const RSSX = 'RSSX';
    const RSUX = 'RSUX';
    const RSVX = 'RSVX';
    const RUCX = 'RUCX';
    const RUKX = 'RUKX';
    const RUMX = 'RUMX';
    const RZSX = 'RZSX';
    const SABR = 'SABR';
    const SABX = 'SABX';
    const SACB = 'SACB';
    const SACX = 'SACX';
    const SADX = 'SADX';
    const SAGX = 'SAGX';
    const SAHE = 'SAHE';
    const SAHX = 'SAHX';
    const SAIX = 'SAIX';
    const SALX = 'SALX';
    const SAMX = 'SAMX';
    const SANX = 'SANX';
    const SAPX = 'SAPX';
    const SARX = 'SARX';
    const SASA = 'SASA';
    const SASX = 'SASX';
    const SATX = 'SATX';
    const SAUX = 'SAUX';
    const SAVX = 'SAVX';
    const SAWX = 'SAWX';
    const SBBJ = 'SBBJ';
    const SBCX = 'SBCX';
    const SBHY = 'SBHY';
    const SBIN = 'SBIN';
    const SBKX = 'SBKX';
    const SBLD = 'SBLD';
    const SBLS = 'SBLS';
    const SBLX = 'SBLX';
    const SBMX = 'SBMX';
    const SBMY = 'SBMY';
    const SBNX = 'SBNX';
    const SBPX = 'SBPX';
    const SBSX = 'SBSX';
    const SBTR = 'SBTR';
    const SBUX = 'SBUX';
    const SCBL = 'SCBL';
    const SCBX = 'SCBX';
    const SCCX = 'SCCX';
    const SCDX = 'SCDX';
    const SCIX = 'SCIX';
    const SCNX = 'SCNX';
    const SCPX = 'SCPX';
    const SCSX = 'SCSX';
    const SCUX = 'SCUX';
    const SDBX = 'SDBX';
    const SDCB = 'SDCB';
    const SDCX = 'SDCX';
    const SDHX = 'SDHX';
    const SDSX = 'SDSX';
    const SDTX = 'SDTX';
    const SDUX = 'SDUX';
    const SEMX = 'SEMX';
    const SENX = 'SENX';
    const SEUX = 'SEUX';
    const SEWX = 'SEWX';
    const SGCX = 'SGCX';
    const SGLX = 'SGLX';
    const SGSX = 'SGSX';
    const SGUX = 'SGUX';
    const SHAX = 'SHAX';
    const SHBK = 'SHBK';
    const SHBX = 'SHBX';
    const SHCX = 'SHCX';
    const SHEX = 'SHEX';
    const SHGX = 'SHGX';
    const SHIX = 'SHIX';
    const SHKX = 'SHKX';
    const SHMX = 'SHMX';
    const SHNX = 'SHNX';
    const SHOX = 'SHOX';
    const SHRX = 'SHRX';
    const SHSX = 'SHSX';
    const SHUX = 'SHUX';
    const SIBL = 'SIBL';
    const SIBX = 'SIBX';
    const SICX = 'SICX';
    const SIDX = 'SIDX';
    const SIGX = 'SIGX';
    const SIHX = 'SIHX';
    const SIKX = 'SIKX';
    const SINX = 'SINX';
    const SIRX = 'SIRX';
    const SISX = 'SISX';
    const SITX = 'SITX';
    const SIWX = 'SIWX';
    const SJGX = 'SJGX';
    const SJSB = 'SJSB';
    const SJSX = 'SJSX';
    const SKCX = 'SKCX';
    const SKKX = 'SKKX';
    const SKNX = 'SKNX';
    const SKSB = 'SKSB';
    const SKUX = 'SKUX';
    const SLAX = 'SLAX';
    const SLCX = 'SLCX';
    const SMBC = 'SMBC';
    const SMBX = 'SMBX';
    const SMCB = 'SMCB';
    const SMEX = 'SMEX';
    const SMMX = 'SMMX';
    const SMNX = 'SMNX';
    const SMPX = 'SMPX';
    const SMSX = 'SMSX';
    const SMTX = 'SMTX';
    const SMUX = 'SMUX';
    const SMVC = 'SMVC';
    const SMWX = 'SMWX';
    const SNAX = 'SNAX';
    const SNBX = 'SNBX';
    const SNCX = 'SNCX';
    const SNDX = 'SNDX';
    const SNGX = 'SNGX';
    const SNKX = 'SNKX';
    const SNLX = 'SNLX';
    const SNPX = 'SNPX';
    const SNSX = 'SNSX';
    const SOGE = 'SOGE';
    const SOLX = 'SOLX';
    const SONX = 'SONX';
    const SPBX = 'SPBX';
    const SPCB = 'SPCB';
    const SPCX = 'SPCX';
    const SPNX = 'SPNX';
    const SPSX = 'SPSX';
    const SPTX = 'SPTX';
    const SRCB = 'SRCB';
    const SRCX = 'SRCX';
    const SREX = 'SREX';
    const SRGX = 'SRGX';
    const SRHX = 'SRHX';
    const SRSX = 'SRSX';
    const SSBL = 'SSBL';
    const SSBX = 'SSBX';
    const SSDX = 'SSDX';
    const SSHX = 'SSHX';
    const SSKX = 'SSKX';
    const SSLX = 'SSLX';
    const SSNX = 'SSNX';
    const SSOX = 'SSOX';
    const SSSX = 'SSSX';
    const SSWX = 'SSWX';
    const STBP = 'STBP';
    const STCB = 'STCB';
    const STCX = 'STCX';
    const STDX = 'STDX';
    const STRX = 'STRX';
    const SUBX = 'SUBX';
    const SUCX = 'SUCX';
    const SUDX = 'SUDX';
    const SULX = 'SULX';
    const SUMX = 'SUMX';
    const SUNB = 'SUNB';
    const SURX = 'SURX';
    const SURY = 'SURY';
    const SUSX = 'SUSX';
    const SUTB = 'SUTB';
    const SUVX = 'SUVX';
    const SVAX = 'SVAX';
    const SVBL = 'SVBL';
    const SVCB = 'SVCB';
    const SVCX = 'SVCX';
    const SVGX = 'SVGX';
    const SVNX = 'SVNX';
    const SVOX = 'SVOX';
    const SVRX = 'SVRX';
    const SVSX = 'SVSX';
    const SWMX = 'SWMX';
    const SWSX = 'SWSX';
    const SYNB = 'SYNB';
    const TACX = 'TACX';
    const TADX = 'TADX';
    const TAMX = 'TAMX';
    const TAPX = 'TAPX';
    const TASX = 'TASX';
    const TBCX = 'TBCX';
    const TBDX = 'TBDX';
    const TBHX = 'TBHX';
    const TBMX = 'TBMX';
    const TBPX = 'TBPX';
    const TBSB = 'TBSB';
    const TBSX = 'TBSX';
    const TBTX = 'TBTX';
    const TBUX = 'TBUX';
    const TCBX = 'TCBX';
    const TCCX = 'TCCX';
    const TCPX = 'TCPX';
    const TCUB = 'TCUB';
    const TCUX = 'TCUX';
    const TDBX = 'TDBX';
    const TDCB = 'TDCB';
    const TDCX = 'TDCX';
    const TDIX = 'TDIX';
    const TDMX = 'TDMX';
    const TDPX = 'TDPX';
    const TDSX = 'TDSX';
    const TECX = 'TECX';
    const TEHX = 'TEHX';
    const TEMX = 'TEMX';
    const TESX = 'TESX';
    const TETX = 'TETX';
    const TFCX = 'TFCX';
    const TGBX = 'TGBX';
    const TGCX = 'TGCX';
    const TGDX = 'TGDX';
    const TGMB = 'TGMB';
    const TGNX = 'TGNX';
    const TGUX = 'TGUX';
    const THCX = 'THCX';
    const THOX = 'THOX';
    const THRX = 'THRX';
    const THWX = 'THWX';
    const TIDX = 'TIDX';
    const TIRX = 'TIRX';
    const TJAX = 'TJAX';
    const TJBX = 'TJBX';
    const TJCX = 'TJCX';
    const TJDX = 'TJDX';
    const TJMX = 'TJMX';
    const TJNX = 'TJNX';
    const TJSB = 'TJSB';
    const TKAX = 'TKAX';
    const TKCX = 'TKCX';
    const TKDX = 'TKDX';
    const TKTX = 'TKTX';
    const TKUX = 'TKUX';
    const TLPX = 'TLPX';
    const TMAX = 'TMAX';
    const TMBL = 'TMBL';
    const TMBX = 'TMBX';
    const TMCX = 'TMCX';
    const TMNX = 'TMNX';
    const TMPX = 'TMPX';
    const TMSX = 'TMSX';
    const TMTX = 'TMTX';
    const TMUX = 'TMUX';
    const TNBX = 'TNBX';
    const TNCX = 'TNCX';
    const TNDC = 'TNDC';
    const TNEX = 'TNEX';
    const TNHX = 'TNHX';
    const TNIX = 'TNIX';
    const TNKX = 'TNKX';
    const TNMX = 'TNMX';
    const TNSC = 'TNSC';
    const TNUX = 'TNUX';
    const TOCX = 'TOCX';
    const TPCX = 'TPCX';
    const TPDX = 'TPDX';
    const TPSX = 'TPSX';
    const TPUX = 'TPUX';
    const TRAX = 'TRAX';
    const TRDX = 'TRDX';
    const TSAB = 'TSAB';
    const TSAX = 'TSAX';
    const TSBX = 'TSBX';
    const TSCX = 'TSCX';
    const TSDX = 'TSDX';
    const TSIX = 'TSIX';
    const TSMX = 'TSMX';
    const TSNX = 'TSNX';
    const TSPX = 'TSPX';
    const TSUX = 'TSUX';
    const TTBX = 'TTBX';
    const TTCB = 'TTCB';
    const TTCX = 'TTCX';
    const TTGX = 'TTGX';
    const TTLX = 'TTLX';
    const TTUX = 'TTUX';
    const TUBX = 'TUBX';
    const TUCX = 'TUCX';
    const TUDX = 'TUDX';
    const TUMX = 'TUMX';
    const TUNX = 'TUNX';
    const TUOX = 'TUOX';
    const TUPX = 'TUPX';
    const TURX = 'TURX';
    const TVBX = 'TVBX';
    const TVDX = 'TVDX';
    const TVPX = 'TVPX';
    const TVUX = 'TVUX';
    const TYCX = 'TYCX';
    const UBBX = 'UBBX';
    const UBGX = 'UBGX';
    const UBIN = 'UBIN';
    const UCBA = 'UCBA';
    const UCBS = 'UCBS';
    const UCBX = 'UCBX';
    const UCCX = 'UCCX';
    const UCDX = 'UCDX';
    const UCUX = 'UCUX';
    const UGBX = 'UGBX';
    const UJSX = 'UJSX';
    const UJVN = 'UJVN';
    const UKGX = 'UKGX';
    const UMAX = 'UMAX';
    const UMCX = 'UMCX';
    const UMSX = 'UMSX';
    const UMUX = 'UMUX';
    const UNAX = 'UNAX';
    const UNIX = 'UNIX';
    const UNMX = 'UNMX';
    const UNSX = 'UNSX';
    const UOVB = 'UOVB';
    const UPCX = 'UPCX';
    const URCX = 'URCX';
    const URDX = 'URDX';
    const URMX = 'URMX';
    const UROX = 'UROX';
    const USNX = 'USNX';
    const UTBI = 'UTBI';
    const UTBX = 'UTBX';
    const UTCX = 'UTCX';
    const UTGX = 'UTGX';
    const UTIB = 'UTIB';
    const UTKS = 'UTKS';
    const UTKX = 'UTKX';
    const UTZX = 'UTZX';
    const UUCX = 'UUCX';
    const VADX = 'VADX';
    const VAIX = 'VAIX';
    const VANX = 'VANX';
    const VARA = 'VARA';
    const VASX = 'VASX';
    const VAUX = 'VAUX';
    const VCAX = 'VCAX';
    const VCBX = 'VCBX';
    const VCCX = 'VCCX';
    const VCNB = 'VCNB';
    const VCOX = 'VCOX';
    const VDCX = 'VDCX';
    const VDYX = 'VDYX';
    const VEDX = 'VEDX';
    const VERX = 'VERX';
    const VGBX = 'VGBX';
    const VHDX = 'VHDX';
    const VICX = 'VICX';
    const VIDX = 'VIDX';
    const VIJB = 'VIJB';
    const VIJX = 'VIJX';
    const VIKX = 'VIKX';
    const VIMX = 'VIMX';
    const VIRX = 'VIRX';
    const VISX = 'VISX';
    const VJSX = 'VJSX';
    const VKCX = 'VKCX';
    const VKSX = 'VKSX';
    const VMCX = 'VMCX';
    const VMMX = 'VMMX';
    const VMUX = 'VMUX';
    const VNSX = 'VNSX';
    const VRDX = 'VRDX';
    const VSBL = 'VSBL';
    const VSBX = 'VSBX';
    const VSCX = 'VSCX';
    const VSSX = 'VSSX';
    const VSVX = 'VSVX';
    const VUCX = 'VUCX';
    const VVCX = 'VVCX';
    const VVSB = 'VVSB';
    const VYAX = 'VYAX';
    const VYPX = 'VYPX';
    const VYSA = 'VYSA';
    const WACX = 'WACX';
    const WAIX = 'WAIX';
    const WARX = 'WARX';
    const WAUX = 'WAUX';
    const WBSC = 'WBSC';
    const WCBX = 'WCBX';
    const WDCX = 'WDCX';
    const WKGX = 'WKGX';
    const WNBX = 'WNBX';
    const WPAC = 'WPAC';
    const WRCX = 'WRCX';
    const WUCX = 'WUCX';
    const WZUX = 'WZUX';
    const XJKG = 'XJKG';
    const YADX = 'YADX';
    const YAVX = 'YAVX';
    const YCBX = 'YCBX';
    const YDCX = 'YDCX';
    const YESB = 'YESB';
    const YLNX = 'YLNX';
    const YMSX = 'YMSX';
    const YNCX = 'YNCX';
    const YNSX = 'YNSX';
    const ZBBX = 'ZBBX';
    const ZBSX = 'ZBSX';
    const ZCBL = 'ZCBL';
    const ZIBX = 'ZIBX';
    const ZILX = 'ZILX';
    const ZIMX = 'ZIMX';
    const ZISX = 'ZISX';
    const ZLLX = 'ZLLX';
    const ZMMX = 'ZMMX';
    const ZSAX = 'ZSAX';
    const ZSBL = 'ZSBL';
    const ZSBX = 'ZSBX';
    const ZSGX = 'ZSGX';
    const ZSHX = 'ZSHX';
    const ZSJX = 'ZSJX';
    const ZSKX = 'ZSKX';
    const ZSLX = 'ZSLX';
    const ZSMX = 'ZSMX';
}
