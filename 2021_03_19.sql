Function (group function 실습 grp3)
emp 테이블을 이용하여 다음을 구하시오
grp2 에서 작성한 쿼리를 활용하여 deptno 대신 부서명이 나올 수 있도록 수정하시오
SELECT CASE 
          CASE
            WHEN deptno = 10  THEN 'ACCOUNTING'
            WHEN deptno = 20  THEN 'RESEARCH'
            WHEN deptno = 30  THEN 'SALES'
            WHEN deptno = 40  THEN 'OPERATIONS'
            ELSE 'DDIT'
            END dname_case,
            MAX(sal), MIN(sal), ROUND(AVG(sal),2), SUm(sal), COUNT (sal), COUNT(mgr),COUNT (*)
FROM emp
GROUP BY deptno;

grp 4
emp테이블을 이용하여 다음을 구하시오 / 직원의 입사 년월별로 몇명의 직원이 입사했는지 조회 쿼리
SELECT TO_CHAR(hiredate, 'yyyymm') hire_yyyymm, count(*)cnt
FROM emp
group by TO_CHAR(hiredate, 'yyyymm');

grp 5
emp 테이블을 이용하여 직원의 입사 년별로 몇명의 직원이 입사했는지 조회

SELECT TO_CHAR(hiredate, 'yyyy') hire_yyyy, count(*)cnt
FROM emp
group by TO_CHAR(hiredate, 'yyyy');

grp 6
회사에 존재하는 부서의 개수는 몇개인지 조회 쿼리 (dept 테이블 사용)
해당테이블에 몇건의 데이터가 있나요?

Select *
from dept;

grp7
직원이 속한 부서의 개수를 조회(emp 테이블 조회)
select count(*)
from              --(2)를 카운트 시킴
(select deptno
from emp          -- emp 테이블의 deptno를 조회 (1)
group by deptno);  -- deptno의 겹치는 행들을 그룹화 시킴 (2)

=====데이터 결합=====
join
rdbms 는 중복이 최소화 하는 형태의 데이터 베이스
다른 테이블과 결합하여 데이터 조회

데이터 확장(결합)
1. 컬럼에 대한 확장 : JOIN
2. 행에대한 확장 : 집합연산자 (UNION ALL, UNION(합집합), MINUS(차집합), INTERSECT(교집합))

JOIN
<중복을 최소화 하는 RDBMS 방식으로 설계한 경우>

-emp테이블에는 부서코드만 존재,
부서정보를 담은 dept 테이블 별도로 생성
-emp 테이블과 dept 테이브의 연결고리로(deptno) 조인하여 실제 부서명을 조회한다

JOIN 
1. 표준 SQL => ANSI SQL 
2. 비표준 SQL - DBMS를 만드는 회사에서 만드는 고유의 SQL 문법

ANSI : SQL
ORACLE : SQL (한방향을 매핑)

ANSI - NATURAL JOIN
 .조인하고자 하는 테이블의 연결컬럼명(타입도 동일)이 동일한 경우(emp.deptno, dept.deptno)
 .연결 컬럼의 값이 동일할때(=) 컬럼이 확장된다
 
 SELECT ename, dname          --특정컬럼만 보고싶을때
 FROM emp NATURAL JOIN dept;
 
SELECT emp.empno, emp.ename, deptno  --NATURAL JOIN 연결고리 컬럼에서 한정사를 쓰지 않음       
FROM emp NATURAL JOIN dept;

ORACLE JOIN : 하나뿐
1. FROM 절에 조인할 테이블을 (,)콤마로 구분하여 나열
2. WHERE : 조인할 테이블의 연결조건을 기술

SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno; --이조건을 만족하는 두테이블의 행을 연결하겠다

7369 SMITH ,7902 FORD
SELECT *
FROM emp, emp
WHERE emp.mgr = emp.empno; -- 에러가 뜸 => 테이블 별칭을 사용해야함

SELECT e.empno, e.ename, m.empno, m.ename  --테이블 별칭을 사용한것
FROM emp e, emp m                          --mgr은 널값이여서 행이 안나옴 따라서 13행만 조회됨
WHERE e.mgr = m.empno;

ANSI SQL : JOIN WITH USING
JOIN하려고 하는 테이블의 컬럼명과 타입이 같은 커럼이 두개 이상인 상황에서
두 컬럼을 모두 조인 조건으로 참여시키지않고, 개발가가 원하는 특정 컬럼으로만 연결을 시키고 싶을때 사용
SELECT *                     
FROM emp JOIN dept USING(deptno);
 --위아래 둘다 같음 --
SELECT *                     
FROM emp, dept                     --오라클 문법(조인이 없음)
WHERE emp.deptno = dept.deptno;

SELECT emp.deptno                     --연결 컬럼에서 한정사 못씀 에러뜸
FROM emp JOIN dept USING(deptno);

<<<JOIN WITH ON : NATURAL JOIN, JOIN WITH USING 을 대체할 수 있는 보편적인 문법
조인 컬럼 조건을 개발자가 임의로 지정
SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno);

--사원 번호, 사원 이름, 해당사원의 상사 사번, 해당사원의 상사 이름 : JOIN WITH ON 을 이용하여 쿼리 작성
단 사원의 번호가 7369에서 7698인 사원들만 조회
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
WHERE e.empno BETWEEN 7369 AND 7698;
--위 조건을 오라클로 바꿈 
--오라클은 실행순서가 없음

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e , emp m                            --SELF JOIN
WHERE e.empno BETWEEN 7369 AND 7698
    AND e.mgr = m.empno;
    
논리적인 조인 형태
1. SELF JOIN : 조인 테이블이 같은 경우
  -계층구조
2. NONEQUI-JOIN : 조인 조건이 =(equals)가 아닌 조인

SELECT *
FROM emp, dept
WHERE  emp.deptno != dept.deptno;  --emp테이블의 부서번호와 dept 테이블의 부서번호가 다를때 연결
                                   -- 한건이 해당하는 건 빼고 묶여 있음  ★시험나옴
                                   
SELECT *
FROM salgrade;

-- salgrade 를 이용하여 직원의 급여 등급 구하기
--empno, ename, sal 급여등급
--ansi, oracle 문법 2가지 버전
--oracle
--FROM 절에 조인할 테이블을 (,)콤마로 구분하여 나열
-- WHERE : 조인할 테이블의 연결조건을 기술
emp.sal >= salgrade.losal
AND
emp.sal<= salgrade.hisal

emp.sal BETWEEN salgarde.losal AND salgarde.hisal

SELECT *
FROM emp e, salgrade s
WHERE e.sal BETWEEN s.losal AND s.hisal; 
--oracle


--ansi
SELECT e.empno, e.ename, e.sal, s.grade                 
FROM emp e JOIN salgrade s ON(e.sal BETWEEN s.losal AND s.hisal);

실습 joim 0
emp, dept 테이블을 이용하여 다음과 같이 조회되도록 쿼리

select empno, ename, emp.deptno, dname         -- 연결컬럼만 어디 컬럼인지 알수 있게 한정자 써줌      
from emp ,dept
where emp.deptno = dept.deptno;

join 1의 부서번호가 10,30인 데이터만 조회

select empno, ename, emp.deptno, dname            
from emp ,dept
where emp.deptno = dept.deptno             -- 행제한은 오라클에서 웨어절에 같이 사용
 and dept.deptno in (10, 20);
 
 join 2
 emp, dept 테이블을 이용하여 다음고 ㅏ같이 조회되도록 쿼리 작성
 급여가 2500초과
 
 select empno, ename, sal, emp.deptno, dname
 from emp, dept
 where emp.deptno = dept.deptno
  and sal > 2500;
  
emp, dept 테이블을 이용하여 다음고 ㅏ같이 조회되도록 쿼리 작성
급여가 2500초과, 사번 7600초과
 select empno, ename, sal, emp.deptno, dname
 from emp, dept
 where emp.deptno = dept.deptno
  and empno > 7600;
  
  급여 2500초과, 사번이 7600보다 크고, research 부서에 속하는 직원
  emp, dept 
 select empno, ename, sal, emp.deptno, dname
 from emp, dept
 where emp.deptno = dept.deptno
  and empno > 7600
  and dname = 'RESEARCH';
  
  가상화가 도입된 이유
  - 물리적 컴퓨터는 동시에 하나의 OS만 실행 가능
  - 성능이 좋은 컴퓨터(서버)라도 하드웨어 자원의 활용이 낮음 : 15~20%
  