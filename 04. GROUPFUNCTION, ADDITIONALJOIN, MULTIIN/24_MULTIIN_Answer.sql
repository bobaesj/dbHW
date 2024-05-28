--1) 다중 컬럼 IN절을 이용해서 기말고사 성적이 80점 이상인 과목번호, 학생번호, 기말고사 성적을 모두 조회하세요.
SELECT CNO
     , SNO
     , RESULT
    FROM SCORE
    WHERE (CNO, SNO) IN (
                            SELECT CNO
                                 , SNO
                                FROM SCORE
                                WHERE RESULT >= 80
                         );

--2) 다중 컬럼 IN절을 이용해서 화학과나 물리학과면서 학년이 1, 2, 3학년인 학생의 정보를 모두 조회하세요.
SELECT SNO
     , SNAME
     , MAJOR
     , SYEAR
    FROM STUDENT
    WHERE (MAJOR, SYEAR) IN (
                                SELECT MAJOR
                                     , SYEAR
                                    FROM STUDENT
                                    WHERE MAJOR IN ('화학', '물리')
                                      AND SYEAR IN (1, 2, 3)
                             );

--3) 다중 컬럼 IN절을 사용해서 부서가 10, 20, 30이면서 보너스가 1000이상인 사원의 사원번호, 사원이름, 부서번호, 부서이름, 업무, 급여, 보너스를 
--   조회하세요.(서브쿼리 사용)
SELECT E.ENO
     , E.ENAME
     , DNO
     , D.DNAME
     , E.JOB
     , E.SAL
     , E.COMM
    FROM EMP E
    NATURAL JOIN DEPT D
    WHERE (E.ENO, DNO) IN (
                              SELECT ENO
                                   , DNO
                                  FROM EMP
                                  WHERE DNO IN ('10', '20', '30')
                                    AND COMM >= 1000
                           );

--4) 다중 컬럼 IN절을 사용하여 기말고사 성적의 최고점이 100점인 과목의 과목번호, 과목이름, 학생번호, 학생이름, 기말고사 성적을 조회하세요.(서브쿼리 사용)
SELECT CNO
     , C.CNAME
     , SNO
     , ST.SNAME
     , SC.RESULT
    FROM COURSE C
    NATURAL JOIN SCORE SC
    NATURAL JOIN STUDENT ST
    WHERE (CNO, SNO) IN (
                            SELECT CNO
                                 , SNO
                                FROM SCORE
                                GROUP BY CNO, SNO
                                HAVING MAX(RESULT) = 100
                         );

--1) WITH 절을 이용하여 정교수만 모여있는 가상테이블 하나와 일반과목(과목명에 일반이 포함되는)들이 모여있는 가상테이블 하나를 생성하여 
--   일반과목들을 강의하는 교수의 정보 조회하세요.(과목번호, 과목명, 교수번호, 교수이름)
WITH
    REGULARPF AS (SELECT * FROM PROFESSOR WHERE ORDERS = '정교수'),
    NORMALCS AS (SELECT * FROM COURSE WHERE CNAME LIKE '일반%')
SELECT NORMALCS.CNO
     , NORMALCS.CNAME
     , PNO
     , REGULARPF.PNAME
    FROM REGULARPF
    NATURAL JOIN NORMALCS;

--2) WITH 절을 이용하여 급여가 3000이상인 사원정보를 갖는 가상테이블 하나와 보너스가 500이상인 사원정보를 갖는 가상테이블 하나를 생성하여
--   두 테이블에 모두 속해있는 사원의 정보를 모두 조회하세요.
WITH
    SALOVER AS (SELECT * FROM EMP WHERE SAL >= 3000),
    COMMOVER AS (SELECT * FROM EMP WHERE COMM >= 500)
SELECT ENO
     , ENAME
     , JOB
     , MGR
     , HDATE
     , SAL
     , COMM
     , DNO
    FROM SALOVER
    NATURAL JOIN COMMOVER;

--3) WITH 절을 이용하여 평점이 3.3이상인 학생의 목록을 갖는 가상테이블 하나와 학생별 기말고사 평균점수를 갖는 가상테이블 하나를 생성하여
--   평점이 3.3이상인 학생의 기말고사 평균 점수를 조회하세요.
WITH
    AVROVER AS (SELECT * FROM STUDENT WHERE AVR >= 3.3),
    AVGRES AS (SELECT SNO, ROUND(AVG(RESULT), 2) AS AVGSC FROM SCORE GROUP BY SNO)
SELECT SNO
     , AVROVER.SNAME
     , AVROVER.AVR
     , AVGRES.AVGSC
    FROM AVROVER
    NATURAL JOIN AVGRES;

--4) WITH 절을 이용하여 부임일자가 25년이상된 교수정보를 갖는 가상테이블 하나와 과목번호, 과목명, 학생번호, 학생이름, 교수번호, 기말고사성적을
--   갖는 가상테이블 하나를 생성하여 기말고사 성적이 90이상인 과목번호, 과목명, 학생번호, 학생이름, 교수번호, 교수이름, 기말고사성적을 조회하세요.
WITH
    HIREOVER AS (SELECT * FROM PROFESSOR WHERE MONTHS_BETWEEN(SYSDATE, HIREDATE) / 12 >= 25),
    COUSTPF AS (
                    SELECT CNO
                         , C.CNAME
                         , SNO
                         , ST.SNAME
                         , C.PNO
                         , SC.RESULT
                        FROM SCORE SC 
                        NATURAL JOIN COURSE C
                        NATURAL JOIN STUDENT ST
                )
SELECT COUSTPF.CNO
     , COUSTPF.CNAME
     , COUSTPF.SNO
     , COUSTPF.SNAME
     , HIREOVER.PNO
     , HIREOVER.PNAME
     , COUSTPF.RESULT
    FROM COUSTPF
    LEFT JOIN HIREOVER
    ON COUSTPF.PNO = HIREOVER.PNO
    WHERE COUSTPF.RESULT >= 90;