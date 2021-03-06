C
C     PROGRAM QUARTETSAC6
C
C     THIS ROUTINE FORMS THE FOUR VECTORS FOR PROGRAM SPARS1.F USING
C     OUTPUT FROM AFTERSHOCKSAC.F
C
C ****THIS CODE HAS BEEN MODIFIED TO WORK WITH TRI-VALLEY DATA****
C
C     Q....VECTOR OF NON-ZERO ELEMENTS OF TRANSPOSE OF A MATRIX. 
C          ALL ITS ELEMENTS ARE 1.0 SO THIS VECTOR IS NOT EXPLICITLY 
C          FORMED BUT ITS LENGTH IS CALCULATED.
C     II...VECTOR OF ROW LOCATIONS OF Q (NON-ZERO ELEMENTS OF A
C          TRANSPOSE)
C     JJ...VECTOR OF COLUMN LOCATIONS OF Q (NON-ZERO ELEMENTS OF A
C          TRANSPOSE)
C     D....VECTOR OF DATA
C
C     THIS VERSION OF THE CODE HAS BEEN MODIFIED TO LOOP OVER BOTH
C     VELOCITY AND ACCELERATION-DERIVED RECORDS FROM SEPARATE NAMES.DAT
C     FILES FOR EACH EVENT. 
C
C     OPTION TO USE RMS VALUE OF TWO HORIZONTAL COMPONENTS OF MOTION.
C
      CHARACTER*5 STA(200),SAVSTA
      CHARACTER*64 NAME,AFLOC,STALOC,STRING
      CHARACTER*5 BLANK
      CHARACTER*7 BLANK2
      CHARACTER*14 AFILE(200)
      CHARACTER*26 STTA(200)
      CHARACTER*40 SPACES
      CHARACTER*24 NAME1
      CHARACTER*1 INSTYP(200)
      CHARACTER*51 NAME2
      DIMENSION CHANALT(3,200),CHANAZI(3,200)
      DIMENSION H(200),SORLAT(200),SORLON(200),STALAT(200),STALON(200),
     +XMAG(200),F(20),Q(20),BEGIN(200),
     +XEND(200),WINDOW(4)
      DIMENSION AMP(16384),U(32768),F1(16384),SAVE(1000),SPACE(16384)
      DIMENSION STASP(1000),SAVE2(1000)
      DIMENSION II(500000),JJ(500000)
      DATA (F(I),I=1,6) / 1.0,1.5,3.0,6.0,12.0,22.0/
      DATA (Q(I),I=1,6) / 83.,105.,200.,384.,666.,1333./
      DATA NUM,VEL / 6,3.25/
C
      INUM=1
      IFRAME=0
      WRITE(6,670)
 670  FORMAT(1X,'DO YOU WANT TO LIMIT THIS RUN TO PLOTTING THE',/,
     +1X,'AVERAGE DATA RECORD SPECTRUM AT A PARTICULAR SITE,',/,
     +1X,'1=YES 0=NO')
      READ(5,*) ISPSV
      IF(ISPSV .EQ. 1) THEN
      WRITE(6,636)
 636  FORMAT(1X,'ENTER THE NAME OF THE STATION TO SAVE')
      READ(5,637) SAVSTA
 637  FORMAT(A)
      DO 50 I=1,1000
  50  STASP(I)=0.
      IRSAV=0
      END IF
      WRITE(6,607)
 607  FORMAT(1X,'ENTER THE NUMBER OF THE COMPONENT (1,2,OR 3)',/,
     +1X,'FROM THE INPUT RECORDS THAT YOU WANT TO PROCESS',/,
     +1X,'1...VERTICAL COMPONENT',/,
     +1X,'2...ROTATED NORTH (RADIAL) COMPONENT',/,
     +1X,'3...ROTATED EAST (TRANSVERSE) COMPONENT',/,
     +1X,'4...RMS OF THE TWO HORIZONTAL COMPONENTS')
      READ(5,*) ICOMP
      WRITE(6,608)
 608  FORMAT(1X,'ENTER THE LENGTH OF THE TAPER WINDOW IN SECONDS',/,
     +1X,'AT THE BEGINNING AND END OF EACH RECORD SECTION TO BE',/,
     +1X,'TRANSFORMED')
      READ(5,*) TAPER
      WRITE(6,609)
 609  FORMAT(1X,'ENTER THE LATITUDE AND LONGITUDE OF A COMMON',/,
     +1X,'REFERENCE POINT NEAR THE AFTERSHOCK EPICENTERS FOR',/,
     +1X,'THE PURPOSE OF CALCULATING DISTANCES. NOT USED.')
      READ(5,*) TCLAT,TCLONG
      WRITE(6,611)
 611  FORMAT(1X,'INDICATE THE FREQUENCY BANDWIDTH, MINIMUM AND',/,
     +1X,'MAXIMUM IN HZ, OVER WHICH YOU WANT THE INVERSION DONE,',/,
     +1X,'AND THE FREQUENCY STEP. TO PRODUCE II, JJ, AND D VECTORS',/,
     +1X,'FOR A SINGLE FREQUENCY, SET FMAX=FMIN')
      READ(5,*) FMIN,FMAX,FSTEP
      WRITE(6,632)
 632  FORMAT(1X,'DO YOU WANT TO SMOOTH THE SPECTRA WITH A RUNNING',/,
     +1X,'MEAN (=1), A SAVGOL FILTER (=2), A 1/3 OCTAVE',/,
     +1X,'BAND-AVERAGE FILTER (=3), A COMBINATION 2/3 - 1/3 -',/,
     +1X,'1/6 BAND-AVERAGE FILTER (=4), OR NUMERICAL RECIPES',/,
     +1X,'FOURIER SMOOTHER (=5)')
      READ(5,*) IFTYPE
      IF(IFTYPE .EQ. 1) THEN
      WRITE(6,612)
 612  FORMAT(1X,'ENTER LENGTH OF RUNNING MEAN FILTER ON SPECTRUM')
      READ(5,*) LENG
      END IF
      IF(IFTYPE .EQ. 2) THEN
      WRITE(6,635)
 635  FORMAT(1X,'ENTER THE THREE SAVGOL FILTER PARAMETERS')
      END IF
      IF(IFTYPE .EQ. 5) THEN
      WRITE(6,638)
 638  FORMAT(1X,'ENTER THE LENGTH OF THE FOURIER SMOOTHER')
      READ(5,*) XLENGF
      END IF
      WRITE(6,633)
 633  FORMAT(1X,'DO YOU WANT TO USE BEGIN AND END TIMES FOR',/,
     +1X,'S-WAVE WINDOWS FROM THE INPUT FILES (=1), OR DO YOU',/,
     +1X,'WANT TO SPECIFY A CONSTANT FIXED WINDOW LENGTH STARTING',/,
     +1X,'AT THE BEGIN TIMES (=2), OR DO YOU WANT TO USE BEGIN',/,
     +1X,'AND DURATION TIMES FOR EACH RECORD FROM THE INPUT FILES (=3)')
      READ(5,*) IWTYPE
      IF(IWTYPE .EQ. 2) THEN
      WRITE(6,634)
 634  FORMAT(1X,'ENTER THE LENGTH IN SECONDS OF THE FIXED WINDOW')
      READ(5,*) FIXDUR
      END IF
      WRITE(6,620)
 620  FORMAT(1X,'ENTER MULTIPLICATIVE SCALE FACTOR IN SEC/UNIT',/,
     +1X,'TO BE USED ON START AND END OF RECORD WINDOW TIMES')
      READ(5,*) SECMM
      WRITE(6,617)
 617  FORMAT(1X,'ENTER THE NUMBER OF POINTS TO BE PLOTTED ACROSS',/,
     +1X,'THE FULL WIDTH OF THE SCREEN')
      READ(5,*) MMT
      WRITE(6,618)
 618  FORMAT(1X,'ENTER THE NUMBER OF TRACES PER PAGE OR FRAME')
      READ(5,*) NPAGE
      WRITE(6,619)
 619  FORMAT(1X,'ENTER HEIGHT OF PLOT AS A FRACTION OF THE TOTAL',/,
     +1X,'SCREEN HEIGHT. IF ZERO, PROGRAM CALCULATES INTERNALLY')
      READ(5,*) HEIGH
      WRITE(6,621)
 621  FORMAT(1X,'SPECIFY BACKGROUND TYPE FOR PLOTS:',/,
     +1X,'1 = PERIMETER BACKGROUND',/,
     +1X,'2 = GRID BACKGROUND',/,
     +1X,'3 = JUST AXES',/,
     +1X,'4 = NO BACKGROUND')
      READ(5,*) IBAK
      WRITE(6,622)
 622  FORMAT(1X,'SPECIFY LINEAR (=0) OR LOGARITHMIC (=1) X, HORIZ.',/,
     +1X,'SCALE')
      READ(5,*) IXTYPE
      WRITE(6,623)
 623  FORMAT(1X,'SPECIFY LINEAR (=0) OR LOGARITHMIC (=1) Y, VERT.',/,
     +1X,'SCALE')
      READ(5,*) IYTYPE
      OPEN(UNIT=9,FILE='DQ.DAT',STATUS='NEW',ACCESS='SEQUENTIAL',
     +FORM='UNFORMATTED')
      OPEN(UNIT=10,FILE='IIQ.DAT',STATUS='NEW',ACCESS='SEQUENTIAL',
     +FORM='UNFORMATTED')
      OPEN(UNIT=11,FILE='JJQ.DAT',STATUS='NEW',ACCESS='SEQUENTIAL',
     +FORM='UNFORMATTED')
      OPEN(UNIT=14,FILE='DISTANCES.DAT',STATUS='NEW')
C
C     FIRST FIND OUT HOW MANY DIFFERENT SOURCES THERE ARE.
C
      WRITE(6,700)
 700  FORMAT(1X,'ENTER THE NAME OF THE FILE IN MASTER.DAT FORMAT',/,
     +1X,'WITH SOURCE LOCATIONS')
      READ(5,637) AFLOC
      OPEN(UNIT=7,FILE=AFLOC,STATUS='OLD')
      IC=1
  4   READ(7,600,END=5) XLAT,XLONG,H(IC),XMAG(IC),AFILE(IC) 
 600  FORMAT(F7.4,1X,F9.4,2F5.2,1X,A)
      SORLAT(IC)=XLAT
      SORLON(IC)=XLONG
      IC=IC+1
      GO TO 4
  5   IC=IC-1
      CLOSE(7)
      NSOR=IC
      WRITE(6,666) (SORLAT(I),SORLON(I),I=1,NSOR)
 666  FORMAT(1X,2F12.3)     
C
C     NOW READ IN SITE INFORMATION.
C
      WRITE(6,702)
 702  FORMAT('ENTER THE NAME OF THE FILE WITH STATION LOCATIONS')
      READ(5,637) STALOC
      OPEN(UNIT=7,FILE=STALOC,STATUS='OLD')
      I=1
  61  READ(7,601,END=60) STRING
      IF(STRING(1:5) .EQ. 'STNID') THEN 
      STA(I)=STRING(7:11)
      READ(7,*) BLANK,STALAT(I),STALON(I),HH
      DO 33 IPC=1,3
      READ(7,*,END=60) BLANK2,ICOM,CHANALT(ICOM,I)
      READ(7,*,END=60) BLANK2,ICOM,CHANAZI(ICOM,I)
  33  CONTINUE
      I=I+1
      END IF
      GO TO 61
  60  CLOSE(7)
 601  FORMAT(A)
      NSIT=I-1
C
C     INPUT FOR Q, KAPPA, AND GEOMMETRICAL SPREADING CORRECTIONS.
C
      WRITE(6,602)
 602  FORMAT(1X,'DO YOU WANT TO CORRECT DATA RECORDS FOR Q,',/,
     +1X,'1=YES  0=NO')
      READ(5,*) IQ
      IF(IQ .EQ. 1) THEN
      WRITE(6,603)
 603  FORMAT(1X,'DO YOU WANT TO TAKE Q VALUES FROM DATA STATEMENT',/,
     +1X,'(=1), OR USE Q = 150*SQRT(FREQUENCY) (=2)')
      READ(5,*) IQTYPE
      WRITE(6,671)
 671  FORMAT(1X,'DO YOU WANT TO TAKE THE SHEAR WAVE VELOCITY',/,
     +1X,'FROM THE DATA STATEMENT (=1), OR USE',/,
     +1X,'VS = 2.5 + .025*DISTANCE (=2)')
      READ(5,*) IVS
      END IF
      WRITE(6,630)
 630  FORMAT(1X,'DO YOU WANT TO CORRECT DATA RECORDS FOR AN',/,
     +1X,'AVERAGE KAPPA VALUE, 1=YES 0=NO')
      READ(5,*) IKAPPA
      IF(IKAPPA .EQ. 1) THEN
      WRITE(6,631)
 631  FORMAT(1X,'ENTER AVERAGE KAPPA VALUE (APPROXIMATELY 0.04)')
      READ(5,*) AVGKAP 
      END IF
      WRITE(6,604)
 604  FORMAT(1X,'DO YOU WANT TO CORRECT DATA RECORDS FOR',/,
     +1X,'GEOMMETRICAL SPREADING. NORMALIZED TO A DISTANCE',/,
     +1X,'OF 10 KM, 1=YES  0=NO')
      READ(5,*) IR
      IF(IR .EQ. 1) THEN
      WRITE(6,605)
 605  FORMAT(1X,'ENTER EXPONENT ON GEOMMETRICAL SPREADING TERM')
      READ(5,*) GAMMA
      END IF
      WRITE(6,624)
 624  FORMAT(1X,'DO YOU WANT THE AMPLITUDE SPECTRA NORMALIZED',/,
     +1X,'BY THE RECORD DURATION, 1=YES 0=NO')
      READ(5,*) NORMAL
      WRITE(6,625)
 625  FORMAT(1X,'DO YOU WANT TO INTEGRATE THE SPECTRA, THAT IS,',/,
     +1X,'GO FROM VELOCITIES TO DISPLACEMENTS,  1=YES 0=NO')
      READ(5,*) INTEG
C
C     LOOP OVER SOURCES.
C
      ICREC=0
      DO 100 ILOOP=1,NSOR
C
C     LOOP OVER VELOCITY AND ACCELERATION RECORDS
C
      IC=1
      DO 300 KLOOP=1,2
      IF(KLOOP .EQ. 1) NAME1(1:24)=AFILE(ILOOP)(1:14)//'NAMESv.DAT'
      IF(KLOOP .EQ. 2) NAME1(1:24)=AFILE(ILOOP)(1:14)//'NAMESa.DAT'
      OPEN(UNIT=7,FILE=NAME1,STATUS='OLD')
  8   READ(7,606,END=7) STTA(IC),BEGIN(IC),XEND(IC)
      READ(7,655) SPACES
      READ(7,655) SPACES
 655  FORMAT(A)
 606  FORMAT(A,2F6.0)
C*****ALL SANTA CLARA RECORDS ARE ASSUMED TO BE ACCELERATION, WHICH ARE
C*****ALL INTEGRATED TO VELOCITY IN AFTERSHOCKSAC.F
      IF(KLOOP .EQ. 1) INSTYP(IC)='V'
      IF(KLOOP .EQ. 2) INSTYP(IC)='V'
      IC=IC+1
      GO TO 8
  7   CLOSE(7)
 300  CONTINUE
      IC=IC-1
      NSTA=IC
      DO 32 I=1,NSTA
      BEGIN(I)=BEGIN(I)*SECMM
  32  XEND(I)=XEND(I)*SECMM
      IF(IWTYPE .EQ. 2) THEN
      DO 37 I=1,NSTA
  37  XEND(I)=BEGIN(I)+FIXDUR
      END IF
      IF(IWTYPE .EQ. 3) THEN
      DO 38 I=1,NSTA
  38  XEND(I)=XEND(I)+BEGIN(I)
      END IF
C
C     LOOP OVER SITES.
C
      DO 200 JLOOP=1,NSIT
      DO 9 I=1,NSTA
      IF(STTA(I)(18:18) .EQ. '_') THEN
      IF(STTA(I)(15:17) .EQ. STA(JLOOP)(1:3)) GO TO 10
      ELSE
      IF(STTA(I)(15:18) .EQ. STA(JLOOP)(1:4)) GO TO 10
      END IF
  9   CONTINUE
      GO TO 200
  10  IK=I
      IF(ISPSV .EQ. 1) THEN
      IF(STTA(I)(18:18) .EQ. '_') THEN
      IF(STTA(I)(15:17) .EQ. SAVSTA(1:3)) GO TO 53 
      ELSE
      IF(STTA(I)(15:18) .EQ. SAVSTA(1:4)) GO TO 53 
      END IF
      GO TO 200
      END IF
  53  ICREC=ICREC+1
      NAME2(1:51)='/zfspool/dk1/tri-valley/process/'//
     +STTA(IK)(1:13)//'P'//INSTYP(IK)(1:1)//STTA(IK)(15:18)
      OPEN(UNIT=7,FILE=NAME2,STATUS='OLD',
     +ACCESS='SEQUENTIAL',FORM='UNFORMATTED')
      WRITE(6,616) NAME2(1:51),BEGIN(IK),XEND(IK)
 616  FORMAT(1X,'FOUND STATION ',A,2F10.2)
      IRMS=0
      READ(7) NT,DT
      READ(7) (AMP(I),I=1,NT)
      IF(ICOMP .EQ. 1) GO TO 11
      READ(7) NT,DT
      READ(7) (AMP(I),I=1,NT)
      IF(ICOMP .EQ. 2 .OR. ICOMP .EQ. 4) GO TO 11
  71  READ(7) NT,DT
      READ(7) (AMP(I),I=1,NT)
  11  CONTINUE 
      NAME=''
      NAME(1:64)='INPUT RECORD '//NAME2(1:51)
      DO 30 I=1,NT
  30  SPACE(I)=AMP(I)
      CALL TRACE(SPACE,NT,MMT,DT,0,1.0,NPAGE,HEIGH,NAME,INUM,
     +IFRAME)
C
C     FFT PARAMETERS
C
      MT=8192
      NN=14
      N=2**NN
      M=2*N
C
C     GEOMMETRICAL SPREADING CORRECTION.
C
      CALL DEGTKM(STALAT(JLOOP),STALON(JLOOP),SORLAT(ILOOP),
     +SORLON(ILOOP),XSE,XSN)
C      XSE=-XSE
      DIST=SQRT(XSE**2 + XSN**2)
      WRITE(14,701) DIST
 701  FORMAT(1X,F10.3)
      R=SQRT(XSE**2 + XSN**2 + H(ILOOP)**2)
      WRITE(6,610) R
 610  FORMAT(1X,'DISTANCE USED IN GEOMMETRICAL SPREADING AND Q CORRECTIO
     +N ',F10.3,' KM.')
      IF(IR .EQ. 1) THEN
      RG=(R/10.)**GAMMA
      DO 15 I=1,NT
  15  AMP(I)=AMP(I)*RG
      END IF
C
C     TAPER RECORDS
C
      TAP2=TAPER/2.
      NB1=(BEGIN(IK)-TAP2)/DT + 0.5
      IF(NB1 .LT. 1) NB1=1
      NB2=(BEGIN(IK)+TAP2)/DT + 0.5
      NE1=(XEND(IK)-TAP2)/DT + 0.5
      NE2=(XEND(IK)+TAP2)/DT + 0.5
      IF(NE2 .GT. NT) THEN
      NE2=NT
      NE1=NT-(TAPER/DT + 0.5)
      END IF 
      DO 12 I=NE1,NE2
      XCOS=COS(2.*3.1415926*FLOAT(I-NE1)/(4.0*FLOAT(NE2-NE1)))
  12  AMP(I)=AMP(I)*XCOS
      DO 14 I=NB1,NB2
      XCOS=COS(2.*3.1415926*FLOAT(NB2-I)/(4.0*FLOAT(NB2-NB1)))
  14  AMP(I)=AMP(I)*XCOS
      NWIND=NE2-NB1+1
      K=NB1
      DO 31 I=1,NWIND
      SPACE(I)=AMP(K)
  31  K=K+1
      NAME=''
      NAME(1:27)='WINDOWED RECORD SECTION    '
      CALL TRACE(SPACE,NWIND,MMT,DT,0,1.0,NPAGE,HEIGH,NAME,INUM,
     +IFRAME)
C
C     REMOVE MEAN FROM RECORDS
C
      XMEAN=0.
      DO 73 I=NB1,NE2
  73  XMEAN=XMEAN+AMP(I)
      XMEAN=XMEAN/FLOAT(NWIND)
      DO 74 I=NB1,NE2
  74  AMP(I)=AMP(I)-XMEAN
C
C     FFT DATA AND CALCULATE AMPLITUDE SPECTRUM
C
      DO 16 I=1,M
  16  U(I)=0.
      K=1
      DO 17 I=NB1,NE2
      U(2*K-1)=AMP(I)
  17  K=K+1
      CALL COOLB(NN,U,-1.)
      DO 18 I=1,M
  18  U(I)=U(I)*DT
      DF=1.0/(N*DT)
      FNQ=1.0/(2.*DT)
      DURSEC=(NE2-NB1+1)*DT
      MT1=MT+1
      K=1
      DO 19 I=2,MT1
      AMP(K)=SQRT(U(2*I-1)**2+U(2*I)**2)
      IF(NORMAL .EQ. 1) AMP(K)=AMP(K)/DURSEC
  19  K=K+1
C
C     Q, AND KAPPA CORRECTIONS
C
      DO 23 I=1,MT
  23  F1(I)=FLOAT(I)*DF
      IF(IQ .EQ. 1) THEN
      DO 20 I=1,MT
      FREQ=FLOAT(I)*DF
      IF(IQTYPE .EQ. 1) CALL GETVAL(F,Q,NUM,FREQ,QVALUE)
      IF(IQTYPE .EQ. 2) QVALUE=150.*SQRT(FREQ)
      IF(IVS .EQ. 1) VELS=VEL
      IF(IVS .EQ. 2) VELS=2.5+.025*R
      IF(IKAPPA .NE. 1) POW=(3.1415926*FREQ*R)/(QVALUE*VELS)
      IF(IKAPPA .EQ. 1) POW=(3.1415926*FREQ)*((R/(QVALUE*VELS))+AVGKAP)
      QFACT=EXP(POW)
  20  AMP(I)=AMP(I)*QFACT
      END IF
      NAME=''
      NAME(1:20)='Q CORRECTED SPECTRUM'
      WINDOW(1)=0.
      WINDOW(2)=0.5
      WINDOW(3)=0.
      WINDOW(4)=0.5
      DO 39 I=1,MT
  39  SPACE(I)=AMP(I)
C      CALL DRAW(F1,SPACE,MT,WINDOW,IBAK,IXTYPE,IYTYPE,NAME)
C
C     FILTER SPECTRUM AND SELECT SECTION TO SAVE
C
      IF(IFTYPE .EQ. 1) THEN
      CALL FILT2(AMP,U,LENG,MT)
      DO 22 I=1,MT
  22  AMP(I)=U(I)
      END IF
      IF(IFTYPE .EQ. 3 .OR. IFTYPE .EQ. 4) THEN
      CALL SMOOTH(AMP,MT,DF,FNQ,IFTYPE)
      END IF
      IF(IFTYPE .EQ. 5) THEN
      CALL SMOOFT(AMP,MT,XLENGF)
      END IF
      IF(FMAX .GT. FNQ) FMAX=FNQ
      IF(FMIN .LT. DF) FMIN=DF
      IFN=(FMAX-FMIN)/FSTEP + 1.5
      DO 24 I=1,IFN
      FVAL=FMIN+FLOAT(I-1)*FSTEP
      CALL INTERP(F1,AMP,MT,FVAL,AMPL)
  24  SAVE(I)=AMPL
C
C     LOOP FOR RMS CALCULATION.
C
      IF(ICOMP .EQ. 4) THEN
      IF(IRMS .EQ. 1) GO TO 72
      DO 70 I=1,IFN
  70  SAVE2(I)=SAVE(I)
      IRMS=1
      GO TO 71
  72  CONTINUE
      DO 75 I=1,IFN
  75  SAVE(I)=SQRT((SAVE(I)**2+SAVE2(I)**2)/2.0)
      END IF
      CLOSE(7)
C
C     CONVERT VELOCITIES TO DISPLACEMENTS AND TAKE LOG OF SPECTRAL VALUES
C
      IF(INTEG .EQ. 1) THEN
      DO 46 I=1,IFN
      FRQ=FMIN+FLOAT(I-1)*FSTEP
  46  SAVE(I)=SAVE(I)/(6.2831853*FRQ)
      END IF
      DO 36 I=1,IFN
      IF(SAVE(I) .LT. 1.0E-08) SAVE(I)=1.0E-08
  36  SAVE(I)=ALOG10(SAVE(I))
C
C     WRITE OUT DATA VECTOR
C
      WRITE(9) ILOOP,JLOOP,IFN,FMIN,FSTEP
      WRITE(9) (SAVE(I),I=1,IFN)
      NAME=''
      NAME(1:26)='WINDOWED FILTERED SPECTRUM'
      WINDOW(1)=0.5
      WINDOW(2)=1.0
      WINDOW(3)=0.
      WINDOW(4)=0.5
      DO 34 I=1,IFN
  34  SPACE(I)=10.**SAVE(I)
      IF(ISPSV .EQ. 1) THEN
      IRSAV=IRSAV+1
      DO 51 I=1,IFN
  51  STASP(I)=STASP(I)+SPACE(I)
      END IF
      DO 35 I=1,IFN
  35  AMP(I)=FMIN+FLOAT(I-1)*FSTEP
      CALL DRAW(AMP,SPACE,IFN,WINDOW,IBAK,IXTYPE,IYTYPE,NAME)
      IFRAME=1
C
C     CALCULATE COLUMN INDEXES
C
      NCOL=IFN*(NSOR+NSIT)
      IP=IFN*(ICREC-1)+1
      N1=(ILOOP-1)*IFN+1
      N2=IFN*NSOR+(JLOOP-1)*IFN+1
      DO 26 I=1,IFN
      JJ(2*IP-1)=N1+I-1
      JJ(2*IP)=N2+I-1
      NJJ=2*IP
  26  IP=IP+1
 200  CONTINUE
 100  CONTINUE
      CLOSE(9)
C
C     PLOT AVERAGE DATA RECORD SPECTRUM AT SPECIFIC SITE
C
      IF(ISPSV .EQ. 1) THEN
      CALL FRAME
      WINDOW(1)=0.
      WINDOW(2)=1.0
      WINDOW(3)=0.
      WINDOW(4)=1.0
      NAME=''
      NAME(1:25)='AVERAGE SPECTRUM AT '//SAVSTA
      DO 52 I=1,IFN
  52  STASP(I)=STASP(I)/FLOAT(IRSAV)
      CALL DRAW(AMP,STASP,IFN,WINDOW,IBAK,IXTYPE,IYTYPE,NAME)
      END IF
C
C     CALCULATE ROW INDEXES
C
      NROW=IFN*ICREC
      NII=2*NROW
      DO 25 I=1,NROW
      II(2*I-1)=I
  25  II(2*I)=I
      IF(NII .NE. NJJ) THEN
      WRITE(6,614) NII,NJJ
 614  FORMAT(1X,'LENGTH OF II ARRAY ',I5,' IS NOT EQUAL TO',/,
     +1X,'LENGTH OF JJ ARRAY ',I5)
      STOP
      END IF
C
C     WRITE OUT ROW AND COLUMN INDEX VECTORS.
C
      WRITE(10) NROW,NCOL,NSOR,NSIT,ICREC,IFN,NII
      WRITE(10) (II(I),I=1,NII)
      CLOSE(10)
      WRITE(11) NROW,NCOL,NSOR,NSIT,ICREC,IFN,NJJ
      WRITE(11) (JJ(I),I=1,NJJ)
      CLOSE(11)
      WRITE(6,615) NROW,NCOL,NSOR,NSIT,ICREC,IFN,NII,NJJ
 615  FORMAT(1X,'NROW= ',I6,/,
     +1X,'NCOL= ',I6,/,
     +1X,'NSOR= ',I5,/,
     +1X,'NSIT= ',I5,/,
     +1X,'ICREC= ',I5,/,
     +1X,'IFN= ',I5,/,
     +1X,'NII= ',I6,/,
     +1X,'NJJ= ',I6)
      CLOSE(14)
      CALL CLSGKS
      STOP
      END
      SUBROUTINE GETVAL(F,TSTAR,NUM,FREQ,VALUE)
C     LINEAR INTERPOLATION OF TSTAR BY F. ANSWER RETURNED IN VALUE.
      DIMENSION F(1),TSTAR(1)
      IF(FREQ .LE. F(1)) THEN
      VALUE=TSTAR(1)
      RETURN
      END IF
      IF(FREQ .GE. F(NUM)) THEN
      VALUE=TSTAR(NUM)
      RETURN
      END IF
      DO 3 I=1,NUM
   3  IF(F(I) .GT. FREQ) GO TO 2
   2  VALUE=TSTAR(I-1) + (TSTAR(I)-TSTAR(I-1))*(FREQ-F(I-1))/
     +(F(I)-F(I-1))
      RETURN
      END
      SUBROUTINE COOLB(NN,DETA,SIGNI)
C     SCALING THE OUTPUT OF COOLB.
C     THE SPECTRUM OF A TIME DOMAIN SIGNAL COMPUTED BY COOLB (-1 CASE) CAN BE
C     TERMED THE "SPECTRA".  TO SCALE THIS "SPECTRA" TO THE SPECTRAL DENSITY,
C     THE RESULT OF AN ANALYTICAL COMPUTATION OF THE FOURIER TRANSFORM OF A FUNC
C     TIME INTERVAL, DT.  IN GOING FROM THE FREQUENCY DOMAIN TO THE TIME DOMAIN
C     (+1 CASE OF COOLB), THE OUTPUT MUST BE DIVIDED BY THE NUMBER OF POINTS,
C     N, IF THE TRANSFORM IS PERFORMED ON THE "SPECTRA" OR MUST BE DIVIDED BY
C     N*DT IF THE TRANSFORM IS PERFORMED ON THE SPECTRAL DENSITY.  THIS ACHIEVES
       DIMENSION DETA(1)
      N=2**(NN+1)
      J=1
      DO 5 I=1,N,2
      IF(I-J)1,2,2
    1 TEMPR=DETA(J)
      TEMPI=DETA(J+1)
      DETA(J)=DETA(I)
      DETA(J+1)=DETA(I+1)
      DETA(I)=TEMPR
      DETA(I+1)=TEMPI
    2 M=N/2
    3 IF(J-M)5,5,4
    4 J=J-M
      M=M/2
      IF(M-2)5,3,3
    5 J=J+M
      MMAX=2
    6 IF(MMAX-N)7,10,10
    7 ISTEP=2*MMAX
      THETA=SIGNI*6.28318531/FLOAT(MMAX)
      SINTH=SIN(THETA/2.)
      WSTPR=-2.0  *SINTH*SINTH
      WSTPI= SIN(THETA)
      WR=1.
      WI=0.
      DO 9 M=1,MMAX,2
      DO 8 I=M,N,ISTEP
      J=I+MMAX
      TEMPR=WR*DETA(J)-WI*DETA(J+1)
      TEMPI=WR*DETA(J+1)+WI*DETA(J)
      DETA(J)=DETA(I)-TEMPR
      DETA(J+1)=DETA(I+1)-TEMPI
      DETA(I)=DETA(I)+TEMPR
    8 DETA(I+1)=DETA(I+1)+TEMPI
      TEMPR=WR
      WR=WR*WSTPR-WI*WSTPI+WR
    9 WI=WI*WSTPR+TEMPR*WSTPI+WI
      MMAX=ISTEP
      GO TO 6
   10 RETURN
      END
      SUBROUTINE FILT2(X,Y,M,NDATA)
C
C     X = INPUT ARRAY
C     Y = FILTERED OUTPUT ARRAY
C     M = LENGTH OF RUNNING MEAN
C     NDATA = LENGHT OF X AND Y
C
      DIMENSION X(1),Y(1)
      P=M
      TT=(2.*P)+1.
      IFLAG=0
      DO 15 I=1,NDATA
  15  Y(I)=X(I)
   4  IFLAG=IFLAG+1
      Y(M+1)=X(M+1)
      MM=M+1
      NN=NDATA-M-1
      DO 10 I=MM,NN
      K=I+M+1
      L=I-M
  10  Y(I+1)=Y(I)+(1.0/TT)*(X(K)-X(L))
      IF(IFLAG .EQ. 2) GO TO 16
      DO 18 I=1,NDATA
  18  X(I)=Y(I)
      GO TO 4
  16  CONTINUE
      RETURN
      END
      SUBROUTINE INTERP(XP,YP,N,X,Y)
      DIMENSION XP(1),YP(1)
      REAL DIF1,DIF2,DIFY,DR
    1 IF (X.GT.XP(N))  GO TO 6
      IF (X.LT.XP(1))  GO TO 6
    2 DO 10  I=1,N
      IF (XP(I)-X) 10,102,3
   10 CONTINUE
    3 K=I-1
      DIF1=XP(I)-XP(K)
      DIF2=XP(I)-X
      RATIO = DIF2/DIF1
      DIFY=ABS(YP(I) - YP(K))
      DR = DIFY*RATIO
      IF (YP(I) .GT. YP(K))  GO TO 4
    5 Y=YP(I) + DR
      RETURN
    4 Y=YP(I)-DR
      RETURN
  102 Y=YP(I)
      RETURN
    6 IF(X.GT.XP(N)) Y=YP(N)
      IF(X.LT.XP(1)) Y=YP(1)
      RETURN
      END
      SUBROUTINE DEGTKM(PLAT,PLON,CLAT,CLON,X,Y)
      PARAMETER (R=6371.0,FAC=0.01745329)
      DLAT=(PLAT-CLAT)*FAC
      OLAT=CLAT*FAC
      OLON=CLON*FAC
      RLON=PLON*FAC
      Y=R*DLAT
      X=(RLON-OLON)*R*COS((DLAT/2.0)+OLAT)
      RETURN
      END
      SUBROUTINE TRACE(SEIS,NT,MT,DT,IFLAG,FACTOR,NPAGE,HEIGH,NAME,INUM,
     +IFRAME)
C
C     PLOTS TRACES ON SUN SCREEN OR LASER PRINTER.
C     SEIS...ARRAY CONTAINING TRACE TO BE PLOTTED
C     NT.....NUMBER OF POINTS IN TRACE
C     MT.....NUMBER OF POINTS TO BE PLOTTED ACROSS THE FULL WIDTH
C            OF THE SCREEN. IF NT IS GREATER THAN MT, MT POINTS ARE
C            PLOTTED.
C     DT.....TIME STEP OF DATA IN SECONDS.
C     IFLAG..IF= 0 NORMAL OPERATION OF SUBROUTINE
C            IF= 1 CORRECTION IS MADE FOR A CHANGE IN TIME STEP USING
C            FACTOR.
C     FACTOR.(NEW DT/OLD DT).
C     NPAGE..NUMBER OF TRACES PER PAGE OR FRAME.
C     HEIGH..HEIGHT OF PLOT AS A FRACTION OF THE TOTAL SCREEN HEIGHT.
C            IF ZERO, PROGRAM CALCULATES INTERNALLY.
C     NAME...NAME OF FILE BEING PLOTTED.
C     INUM...PLOT COUNTER. INCREMENTS FOR EACH TRACE PLOTTED,
C            STARTING WITH A VALUE OF 1.
C     IFRAME.IF= 0 NORMAL OPERATION OF SUBROUTINE.
C            IF= 1 FORCES A CALL TO FRAME BEFORE PLOTTING THIS TRACE.
C
      DIMENSION SEIS(1)
      DIMENSION IASF(13)
      CHARACTER*12 B,S
      CHARACTER*64 NAME
      DATA IASF /13*1/
      YMOV=0.9/FLOAT(NPAGE)
      IF(HEIGH .EQ. 0.) HH=0.9*YMOV
      IF(HEIGH .NE. 0.) HH=HEIGH
      HH2=HH/2
      DX=1.0/FLOAT(MT)
      IF(INUM .EQ. 1) THEN
      CALL SETUSV('MU',8)
      CALL OPNGKS
      CALL GSASF(IASF)
      CALL GSCR(1,0,1.,1.,1.)
      CALL GSCR(1,1,0.,0.,1.)
      CALL FRAME
      CALL SET(0.,1.,0.,1.,0.,1.,0.,1.,1)
      YPOS=1.-0.1*YMOV-HH2
      IC=0
      END IF
      IC=IC+1
      IF(IC .GT. NPAGE .OR. IFRAME .EQ. 1) THEN
      CALL FRAME
      IC=1
      IFRAME=0
      YPOS=1.-0.1*YMOV-HH2
      END IF
      BIG=0.
      SMALL=0.
      DO 10 I=1,MT
      IF(I .GT. NT) GO TO 20
      BIG=AMAX1(SEIS(I),BIG)
  10  SMALL=AMIN1(SEIS(I),SMALL)
  20  WRITE(B(1:12),'(F12.6)') BIG
      WRITE(S(1:12),'(F12.6)') SMALL
      Y=YPOS-HH2
      X=0.
      CALL PLCHMQ(X,Y,B,.01,0.,-1.)
      X=X+.15
      CALL PLCHMQ(X,Y,S,.01,0.,-1.)
      X=X+.15
      CALL PLCHMQ(X,Y,NAME,.01,0.,-1.)
      SCALE=HH/(BIG-SMALL)
      IF(IFLAG .GE. 0) DXX=DX
      IF(IFLAG .GE. 1) DXX=DX*FACTOR
      X=0.
      Y=SEIS(1)*SCALE + YPOS
      CALL PLOTIF(X,Y,0)
      DO 30 I=1,MT
      IF(I .GT. NT) GO TO 40
      Y=SEIS(I)*SCALE + YPOS
      CALL PLOTIF(X,Y,1)
  30  X=X+DXX
  40  CALL PLOTIF(X,Y,2)
      YPOS=YPOS-YMOV
      INUM=INUM+1
      IF(IC .EQ. NPAGE) THEN
      SEC=(1.0/DT)*DXX
      TIME=FLOAT(MT-1)*DT
      NTICK=INT(TIME)
      X=0.
      Y=0.05
      CALL PLOTIF(X,Y,0)
      DO 50 I=1,NTICK
      Y=Y+0.025
      CALL PLOTIF(X,Y,1)
      Y=Y-0.025
      CALL PLOTIF(X,Y,1)
      X=X+SEC
  50  CALL PLOTIF(X,Y,1)
      CALL PLOTIF(X,Y,2)
      END IF
      RETURN
      END
      SUBROUTINE DRAW(X,Y,NT,WINDOW,IBAK,IXTYPE,IYTYPE,NAME)
C
C     X......ARRAY OF X (HORIZONTAL) COORDINATE VALUES
C     Y......ARRAY OF Y (VERTICAL) COORDINATE VALUES
C     NT.....NUMBER OF POINTS IN X AND Y
C     WINDOW.FOUR ELEMENT ARRAY SPECIFYING THE GRAPH WINDOW
C            AS FRACTIONS OF THE SCREEN DIMENSIONS.
C            WINDOW(1)= LEFT LIMIT
C            WINDOW(2)= RIGHT LIMIT
C            WINDOW(3)= BOTTOM LIMIT
C            WINDOW(4)= TOP LIMIT.
C     IBAK...BACKGROUND PARAMETER.
C            IBAK= 1, PERIMETER BACKGROUND
C            IBAK= 2, GRID BACKGROUND
C            IBAK= 3, JUST AXES
C            IBAK= 4, NO BACKGROUND
C     IXTYPE.SPECIFIES LINEAR (=0) OR LOGARITHMIC (=1) X SCALE.
C     IYTYPE.SPECIFIES LINEAR (=0) OR LOGARITHMIC (=1) Y SCALE.
C     NAME...TITLE FOR PLOT.
C
      DIMENSION X(1),Y(1),WINDOW(4)
      CHARACTER*12 LNLG(2)
      CHARACTER*64 NAME
      IF(IXTYPE .EQ. 0) LNLG(1)='LINEAR$'
      IF(IXTYPE .EQ. 1) LNLG(1)='LOGARITHMIC$'
      IF(IYTYPE .EQ. 0) LNLG(2)='LINEAR$'
      IF(IYTYPE .EQ. 1) LNLG(2)='LOGARITHMIC$'
      CALL AGSETI('FRAME.',2)
      CALL AGSETP('GRAPH WINDOW.',WINDOW(1),4)
      CALL AGSETI('BACKGROUND TYPE.',IBAK)
      CALL AGSETI('X/LOGARITHMIC.',IXTYPE)
      CALL AGSETI('Y/LOGARITHMIC.',IYTYPE)
      CALL AGSETC('LABEL/NAME.','B')
      CALL AGSETI('LINE/NUMBER.',-100)
      CALL AGSETC('LINE/TEXT.',LNLG(1))
      CALL AGSETC('LABEL/NAME.','L')
      CALL AGSETI('LINE/NUMBER.',100)
      CALL AGSETC('LINE/TEXT.',LNLG(2))
      CALL EZXY(X,Y,NT,NAME)
      CALL SET(0.,1.,0.,1.,0.,1.,0.,1.,1)
      RETURN
      END
	subroutine smooth(a,npts,df,fn,iftype)
c 	this subroutine computes the 1/3 octave band-average of
c	an input amplitude or power spectrum. The resultant smoothing
c	is designed to reduce the variance in the spectral estimates.
c	Original code by John Orcutt 17AUG79.
c	T.C. Steve Harmsen, USGS-NNWSI, Golden, Co. 303-236-1603.
c	June 6, 1988. 
c
	dimension a(1),b(8192)
c df=freq. sampling interval (hz)
	top=2.**(1./6.)
	bottom=1.0/top
	f=0.0
	nztot=npts/2
	do 1 i=1,nztot
1	b(i)=a(i)
	do 2 i=1,nztot
	f=f+df
        pow=1.
        if(iftype .eq. 4 .and. f .lt. 1.5) pow=2.
        if(iftype .eq. 4 .and. f .gt. 8.0) pow=0.5
	t=1./f
	tu=t*top**pow
	tb=t*bottom**pow
	fb=1./tu
	fu=1./tb
	do 3 j=i,nztot
	fc=f+df*(j-i+1)
	k=(j-i)+1
	if(fc.gt.fu)goto 4
	if(fc.gt.fn)goto 4
3	continue
4	k=k-1
	do 5 j=1,i
	fc=f-df*j
	l=j
	if(fc.lt.fb)goto 6
	if(fc.lt.df)goto 6
5	continue
6	l=l-1
	no=k+l+1
	sum=b(i)
	if(k.eq.0)goto 70
	do 7 j=1,k
7	sum=sum+b(j+i)
70	continue
	if(l.eq.0)goto 80
	do 8 j=1,l
8	sum=sum+b(i-j)
80	continue
	sum=sum/no
2	a(i)=sum
	return
	end
      SUBROUTINE SMOOFT(Y,N,PTS)
      DIMENSION Y(1)
      MMAX=16384
      M=2
      NMIN=N+2.*PTS
  1   IF(M .LT. NMIN) THEN
      M=2*M
      GO TO 1
      END IF
      IF(M .GT. MMAX) THEN
      WRITE(6,600) M,MMAX
  600 FORMAT(1X,'M= ',I10,' IS GREATER THAN MMAX= ',I10,' IN SMOOFT')
      STOP
      END IF
      CONST=(PTS/M)**2
      Y1=Y(1)
      YN=Y(N)
      RN1=1./(N-1.)
      DO 11 J=1,N
      Y(J)=Y(J)-RN1*(Y1*(N-J)+YN*(J-1))
  11  CONTINUE
      IF(N+1 .LE. M) THEN
      DO 12 J=N+1,M
      Y(J)=0.
  12  CONTINUE
      END IF
      MO2=M/2
      CALL REALFT(Y,MO2,1)
      Y(1)=Y(1)/MO2
      FAC=1.
      DO 13 J=1,MO2-1
      K=2*J+1
      IF(FAC .NE. 0.) THEN
      FAC=AMAX1(0.,(1.-CONST*J**2)/MO2)
      Y(K)=FAC*Y(K)
      Y(K+1)=FAC*Y(K+1)
      ELSE
      Y(K)=0.
      Y(K+1)=0.
      END IF
  13  CONTINUE
      FAC=AMAX1(0.,(1.-0.25*PTS**2)/MO2)
      Y(2)=FAC*Y(2)
      CALL REALFT(Y,MO2,-1)
      DO 14 J=1,N
      Y(J)=RN1*(Y1*(N-J)+YN*(J-1))+Y(J)
  14  CONTINUE
      RETURN
      END
      SUBROUTINE realft(data,n,isign)
      INTEGER isign,n
      REAL data(1)
CU    USES four1
      INTEGER i,i1,i2,i3,i4,n2p3
      REAL c1,c2,h1i,h1r,h2i,h2r,wis,wrs
      DOUBLE PRECISION theta,wi,wpi,wpr,wr,wtemp
      theta=3.141592653589793d0/dble(n/2)
      c1=0.5
      if (isign.eq.1) then
        c2=-0.5
        call four1(data,n/2,+1)
      else
        c2=0.5
        theta=-theta
      endif
      wpr=-2.0d0*sin(0.5d0*theta)**2
      wpi=sin(theta)
      wr=1.0d0+wpr
      wi=wpi
      n2p3=n+3
      do 11 i=2,n/4
        i1=2*i-1
        i2=i1+1
        i3=n2p3-i2
        i4=i3+1
        wrs=sngl(wr)
        wis=sngl(wi)
        h1r=c1*(data(i1)+data(i3))
        h1i=c1*(data(i2)-data(i4))
        h2r=-c2*(data(i2)+data(i4))
        h2i=c2*(data(i1)-data(i3))
        data(i1)=h1r+wrs*h2r-wis*h2i
        data(i2)=h1i+wrs*h2i+wis*h2r
        data(i3)=h1r-wrs*h2r+wis*h2i
        data(i4)=-h1i+wrs*h2i+wis*h2r
        wtemp=wr
        wr=wr*wpr-wi*wpi+wr
        wi=wi*wpr+wtemp*wpi+wi
11    continue
      if (isign.eq.1) then
        h1r=data(1)
        data(1)=h1r+data(2)
        data(2)=h1r-data(2)
      else
        h1r=data(1)
        data(1)=c1*(h1r+data(2))
        data(2)=c1*(h1r-data(2))
        call four1(data,n/2,-1)
      endif
      return
      END
      SUBROUTINE four1(data,nn,isign)
      INTEGER isign,nn
      REAL data(1)
      INTEGER i,istep,j,m,mmax,n
      REAL tempi,tempr
      DOUBLE PRECISION theta,wi,wpi,wpr,wr,wtemp
      n=2*nn
      j=1
      do 11 i=1,n,2
        if(j.gt.i)then
          tempr=data(j)
          tempi=data(j+1)
          data(j)=data(i)
          data(j+1)=data(i+1)
          data(i)=tempr
          data(i+1)=tempi
        endif
        m=n/2
1       if ((m.ge.2).and.(j.gt.m)) then
          j=j-m
          m=m/2
        goto 1
        endif
        j=j+m
11    continue
      mmax=2
2     if (n.gt.mmax) then
        istep=2*mmax
        theta=6.28318530717959d0/(isign*mmax)
        wpr=-2.d0*sin(0.5d0*theta)**2
        wpi=sin(theta)
        wr=1.d0
        wi=0.d0
        do 13 m=1,mmax,2
          do 12 i=m,n,istep
            j=i+mmax
            tempr=sngl(wr)*data(j)-sngl(wi)*data(j+1)
            tempi=sngl(wr)*data(j+1)+sngl(wi)*data(j)
            data(j)=data(i)-tempr
            data(j+1)=data(i+1)-tempi
            data(i)=data(i)+tempr
            data(i+1)=data(i+1)+tempi
12        continue
          wtemp=wr
          wr=wr*wpr-wi*wpi+wr
          wi=wi*wpr+wtemp*wpi+wi
13      continue
        mmax=istep
      goto 2
      endif
      return
      END
