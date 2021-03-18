date
날짜조작 
ex. ROUND(hiredate, 'YYYY') 

날짜관련 함수
MONTHS_BEWTEEN : 두 일자의 사이의 개월 수 --> 인자 - start date,end date, 반환값 
=> 얘만 숫자 반환

ADD_MONTHS(***)
인자 : date, number 더할 개월 수 : date 로 부터 x개월 뒤의 날짜 
--> 존재이유 : date + 90(정수) <- 상황에 따라 달라짐 그 부분때문에 쓰임
--1/15 3개월 뒤의 날짜

NEXT_DAY(***)
인자 : date, number(weekday, 주간일자)
date 이후의 가장 첫번째 주간일자에 해당하는 date를 반환

LAST_DAT(***)
인자 : date : date가 속한 월의 마지막 일자를 date로 반환


MONTHS_BETWEEN
SELECT ename, TO_CHAR(hiredate,'yyyy/mm/dd HH24:mi:ss') hiredate,
    MONTHS_BETWEEN(sysdate, hiredate) months_between,
    ADD_MONTHS(sysdate, 5) ADD_MONTHS,
    ADD_MONTHS(TO_DATE('2021-02-15','YYYY-MM-DD'), -5) add_months2,
    NEXT_DAY(SYSDATE, 6) NEXT_DAY, --현재 시간 18일 이후에 등장하는 첫번째 금요일 언제냐 >19일
    LAST_DAY(SYSDATE),
    TO_DATE(TO_CHAR(SYSDATE,'YYYYMM') ||'01', 'YYYYMMDD') first_day
    --SYSDATE를 이용하영 SYSDATE가 속한 월의 첫번째 날짜 구하기
    --sysdat를 이용해서 년월까지 문자로 구하기 + || '01'
    --'202103' || '01' ==> '20210301'
FROM emp;
--근속연수를 물어볼때 사용(입사일자부터 몇개월이 지났느지 알수있음)

select to_date('2021'|| '0101', 'yyyymmdd' )
from dual;
파라미터로 YYYMM형식의 문자열을 사용하여 (EX. YYYYMM=201912)
해당 년월에 해당하느 일자 수를 구해라


last_day(날짜)

select :YYYYMM, 
    TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD') DT
FROM dual;

-형변환
.명시적 형변환
TO_DATE, TO_CHAR, TO_NUMBER
.묵시적 형변환

SELECT *
FROM emp
WHERE TO_CHAR(empno) = '7369';

1. 위에서 아래로
2. 단 들여쓰기되어있을 경우(자식 노드)자식노드부터 읽는다

NUMBER
포맷
9: 숫자 -> 값을 모를 때 가장 크게 쓰면됨 
0: 강제로 0표시
,: 1000자리 표시
.: 소수점 
L: 화폐단위 (사용자 지정)
$: 달러화폐표시

NULL 처리 함수 : 4가지
NVL(expr1, expr2):expr1 이 NULL 값이 아니면 expr1을 사용하고,expr1 이 NULL값이면 expr2로 대체해서 사용 -- 컬럼이든 가공된 값이든 값이 옴
if(expr1 == null)
    System.out.println(expr2)
else
    System.out.printin(expr1)
    
emp테이블에서 comm컬럼의 값이 null일 경우 0으로 대체해서 조회하기
select empno, comm, NVL(comm,0)
from emp;


select empno, sal, comm, sal + NVL(comm,0) nvl_sal_comm
from emp;

NVL1 **가장 많이 사용
select empno, sal, comm, 
        sal + NVL(comm,0) nvl_sal_comm,
        NVL(sal + comm, 0) nvl_sal_comm2 -- sal과 comm 중 null 있으면 둘값이 0으로 바꿈
from emp;

NVL2 (expr1, expr2, expr3)
if(expr1 != null)
    System.out.println(expr2);
else
    System.out.printin(expr3);
    
comm이 null이 아니면 sal+ comm을 반환,
comm이 null이면 sal을 반환
SELECT empno, sal, comm,
       NVL2(comm, sal+comm, sal)
        sal + NVL(comm,0) nvl_sal_comm 
FROM emp;

NULLIF(expr1, expr2) 
if (expr1 ==expr2)
    System.out.println(null);
else
    System.out.printin(expr1);
    
SELECT empno, sal, NULLIF(sal, 1250)
FROM emp;

COALESCE(expr1, expr2,...) -- (재귀함수)
인자들 중에 가장 먼저 등장하는 null이 아닌 인자를 반환
if(expr1 != null)
    System.out.println(expr1);
else
    COALESCE(expr1, expr2,...);
if(expr2 != null)
    System.out.println(expr2);
else
    COALESCEexpr2,...);    

SELECT empno, sal, comm, COALESCE
FROM emp;

--null 실습 fn 4
emp테이블의 정보를 다음과 같이 조회되도록 쿼리 작성
(nvl, nvl2,coalesce)

SELECT empno, ename, mgr,
    NVL(mgr,9999) mgr_n_1,
    NVL2(mgr, mgr ,9999) mgr_n_2,
    COALESCE(mgr, 9999) mgr_n_3
FROM emp;

users 테이블의 정보를 다음과 같이 조회되도록 쿼리
reg_dt가 null일 경우 sysdate를 적용

SELECT userid, usernm, reg_dt,
        NVL(reg_dt, sysdate)
FROM users
WHERE userid IN('cony','sally','james','moon'); --행을 제한 했을 때 사용

조건분기
1. CASE 절
    CASE expr1 비교식(참거짓을 판단 할 수 있는 수식) THEN 사용할 값(반환할 값) => if
    CASE expr2 비교식(참거짓을 판단 할 수 있는 수식) THEN 사용할 값2(반환할 값2) => else if
    CASE expr3 비교식(참거짓을 판단 할 수 있는 수식) THEN 사용할 값3(반환할 값3) => else if   
    ELSE 사용할 값 4                                                        => else
    END
    
2. DECODE 함수 => COALESCE 함수처럼 가변인자 사용
   DECODE(expr1, search1, return1, search2, return2, search3, rethrn3, ...) // 대소비교 불가능
   DECODE(expr1, 
        search1, return1, 
        search2, return2,
        search3, rethrn3, 
        ... defult)
   if(expr1 == search1)
    System.out.println(return1);
    else if(expr1 == search2)
    System.out.println(return); 
    else if(expr1 == search3)
    System.out.println(return3);
    
직원들의 급여를 인상하려고 한다
job이 SALESMAN  이면 현재 급여에서 5% 인상
job이 MANAGER이면 현재 급여에서 10% 인상
job이 PRESIDENT  이면 현재 급여에서 20% 인상
그 외의 직군은 현재 급여 유지

SELECT ename, job, sal, -- 인상된 급여
        CASE
            WHEN job = 'SALESMAN' THEN sal *1.05
            WHEN job = 'MANAGER' THEN sal *1.10
            WHEN job = 'PRESIDENT' THEN sal *1.20
            ELSE sal *1.0  
        END sal_bonus,
        DECODE(job,
                'SALESMAN', sal* 1.05,
                'MANAGER', sal* 1.10,
                'PRESIDENT', sal* 1.20,
                sal* 1.0) sal_bonus_decode
FROM emp;


emp 테이블을 이용하여 deptno에 따라 부서명으로 변경 해서 다음고 ㅏ같이 조회쿼리
10 -> 'ACCOUNTING'
20->'RESEARCH'
30 -> 'SALES'
40 => 'OPERATIONS'
기타 다른값 => 'DDIT'

SELECT empno, ename, deptno,
          CASE
            WHEN deptno = 10  THEN 'ACCOUNTING'
            WHEN deptno = 20  THEN 'RESEARCH'
            WHEN deptno = 30  THEN 'SALES'
            WHEN deptno = 40  THEN 'OPERATIONS'
            ELSE 'DDIT'
            END
FROM emp;

emp 테이블을 이용하여 hiredate에 따라 올해 건강보험 검진 대상자인지 조회하는 쿼리 작성
(생년을 기준으로 하나 여기서는 입사년도 기준)
홀수년도 - 홀수해 출생자

SELECT empno, ename, hiredate,
        CASE
            WHEN hiredate = 'SALESMAN' THEN sal *1.05
            WHEN hiredate = 'MANAGER' THEN sal *1.10
            WHEN hiredate= 'PRESIDENT' THEN sal *1.20
            ELSE sal *1.0  
        END
FROM emp;

SELECT MOD(1981, 2)
FROM dual;

SELECT empno, ename, hiredate,
        CASE
            WHEN
                MOD(TO_CHAR(hiredate, 'yyyy'),2) = 
                MOD(TO_CHAR(SYSDATE, 'yyyy'),2) THEN '건강검진 대상자'
            ELSE '건강검진 비대상자'
                END CONTACT_TO_DOCTOR
FROM emp;

------다시해보기------
SELECT empno, ename, hiredate,
       DECODE(MOD(TO_CHAR(hiredate, 'yyyy'),2), 
              MOD(TO_CHAR(SYSDATE, 'yyyy'),'건강검진 대상자'),
              '건강검진 비대상자')
FROM emp;

users 테이블을 이용하여 reg_dt에 따라 올해 건강보험 검진 대상자인지 조회 쿼리
(생년을 기준으로 하난 여기는 reg_dt 기준)

SELECT userid, usernm, reg_dt,
        CASE
            WHEN
                MOD(TO_CHAR(reg_dt, 'yyyy'),2) = 
                MOD(TO_CHAR(SYSDATE, 'yyyy'),2) THEN '건강검진 대상자'
            ELSE '건강검진 비대상자'
                END CONTACT_TO_DOCTOR
FROM users
WHERE userid IN ('brown','cony','sally','james','moon');

GROUP FUNCTION : 여러행을 그룹으로 하여 하나의 행으로결과값을 반환하는 함수
                기준이 중요/ 여러컬럼 가능
                WHERE 절 다음 나옴 (WHERE 절과 ORDER BY 사이)
AVG : 평균
COUNT: 건수
MAX: 최대
MIN: 최소
SUM: 합계

SELECT *
FROM emp;

10,5000
20, 3000
30, 2850

SELECT deptno, MAX(sal), MIN(sal), ROUND (AVG(sal),2),
                SUM(sal), COUNT(sal), -- 그룹핑된 행중에 sal컴럼의 값이 null이 아닌 행의 건수
                count(mgr),           -- 그룹핑된 행중에 mgr컬럼의 null값이 아닌 행의 건수
                count(*)              -- 그룹핑된 행 건수
FROM emp
GROUP BY deptno;


SELECT COUNT (*), MAX(sal), MIN(sal), ROUND(AVG(sal),2), SUm(sal)  --그룹아이를 사용하지 않을 경우 테이블의 모든 행을 하나의 행으로 그룹핑 
FROM emp;

--group by 절에 나온 컬럼이 select 절에 그룹함수가 적용되지 않은채로 기술되면 에러
SELECT deptno, empno,
                MAX(sal), MIN(sal), ROUND (AVG(sal),2),
                SUM(sal), COUNT(sal), -- 그룹핑된 행중에 sal컴럼의 값이 null이 아닌 행의 건수
                count(mgr),           -- 그룹핑된 행중에 mgr컬럼의 null값이 아닌 행의 건수
                count(*)              -- 그룹핑된 행 건수
FROM emp
GROUP BY deptno, --empno;   <-  넣어야 정답
--위에 에러 해결하는 법은 select 절에 그룹함수 적용 안된 컬럼은 group by 절에 넣기 

--에러
SELECT deptno COUNT (*), MAX(sal), MIN(sal), ROUND(AVG(sal),2), SUm(sal)  --그룹아이를 사용하지 않을 경우 테이블의 모든 행을 하나의 행으로 그룹핑 
FROM emp
--GROUP BY deptno;OR SELECT 절에 MAX(deptno)해야됨

--'test'가 고정된 값 (=상수) 이므로 에러 발생안함
SELECT deptno, 'test',
                MAX(sal), MIN(sal), ROUND (AVG(sal),2),
                SUM(sal), COUNT(sal), -- 그룹핑된 행중에 sal컴럼의 값이 null이 아닌 행의 건수
                count(mgr),           -- 그룹핑된 행중에 mgr컬럼의 null값이 아닌 행의 건수
                count(*)              -- 그룹핑된 행 건수
FROM emp
GROUP BY deptno;

--그룹함수는 null값이 무시가됨 sum에 NVL처리 안해도됨
SELECT deptno, 'test', 100
                MAX(sal), MIN(sal), ROUND (AVG(sal),2),
                SUM(sal), COUNT(sal), -- 그룹핑된 행중에 sal컴럼의 값이 null이 아닌 행의 건수
                count(mgr),           -- 그룹핑된 행중에 mgr컬럼의 null값이 아닌 행의 건수
                count(*)              -- 그룹핑된 행 건수
                SUM(NVL(comm,0)),
                NVL(SUMcomm),0) --위에와 둘중 이게 더 나음 
FROM emp
GROUP BY deptno
HAVING COUNT(*) >= 4; --

그룹함수에서 NULL컬럼은 계산에서 제외
group by 에 작성된 컬럼 이외의 컬럼이 select 절에올 수 없다
where절에 그룹 함수를 조건으로 사용할 수 없다
    having 절 사용
    - where sum(sal)> 3000(x)
     having sum(sal) > 3000(o)

emp 테이블을 이용하여 다음을 구하시오
-직원중 가장 높은 급여
직원중 가장 낮은 급여
직원의 급여 평균(소수점 두자리까지 나오도록 반올림)
직원의 급여 합
직원중 급여가 있는 직원의수 (null제외)
직원중 상급자가 있는 직원의수 (null제외)
전체 직원의 수

--실습 gru2
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal),2), SUm(sal), COUNT (sal), COUNT(mgr),COUNT (*)
FROM emp;
