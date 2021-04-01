COUNT AVG MIN MAX 

SELECT empno, ename, deptno,
        COUNT(*) OVER (PARTITION BY deptno) cnt
FROM emp;

분석함수를 이용하여 모든 사원에 대해 사원 번호 사원이름 본인 급여 부서번호와 해당 사원이속한 부서의 급여평군을 조회하는 쿼리 작성
(급여평균은 소수점 둘째자리까지 구함)

SELECT empno, ename, sal, deptno,
    ROUND(AVG(sal) OVER (PARTITION BY deptno), 2) avg_sal,
    --해당부서의 가장 낮은 급여
    ROUND(MIN(sal) OVER (PARTITION BY deptno), 2) min_sal,
    --해당부서의 가장 높은 급여
    ROUND(MAX(sal) OVER (PARTITION BY deptno), 2) max_sal,
    COUNT(*)OVER (PARTITION BY deptno)cnt_sal,
    SUM(sal)OVER (PARTITION BY deptno) sum_sal
FROM emp ;

다른 행의 컬럼값 가져오기
--중복을 만들지않고 분석함수 사용

- LAG(col)
 파티션별 윈도우에서 이전 행의 컬럼 값
- LEAD(col)
 파티션별 윈도우에서 이후 행의 컬럼값
 
 자신보다 급여순의가 한단계 낮은 사람의 급여를5번째 컬럼으로 생성 --전체영역 /급여로 순서/ 이후행
 SELECT empno, ename, hiredate, sal,
        LEAD(sal) OVER (ORDER BY sal DESC, hiredate)
 FROM emp;
 
 분석함수를 이용하여 모든 사원에대해 사원번호, 사원이름, 입사일자, 급여,전체 사원중 급여 순위가 1단게 높은 사람의 급여를 조회하는 쿼리작성
 (급여가 같을 경우 입사일이 빠른 사람 높은 순위)
 
 SELECT empno, ename, hiredate, sal,
        LAG(sal) OVER (ORDER BY sal DESC, hiredate)
FROM emp;

분서함수를 사용하지 않고 모든 사원에대해 사원번호, 사원이름, 입사일자, 급여,전체 사원중 급여 순위가 1단게 높은 사람의 급여를 조회하는 쿼리작성
 (급여가 같을 경우 입사일이 빠른 사람 높은 순위)

SELECT a.empno, a.ename, a.hiredate ,a.sal, b.sal
FROM 
(SELECT a.*, ROWNUM rn --(2)
FROM 
(select empno, ename, hiredate, sal --(1)
 from emp
 order by sal DESC, hiredate)a) a,
 
 (SELECT a.*, ROWNUM rn --(2)
FROM 
(select empno, ename, hiredate, sal --(1)
 from emp
 order by sal DESC, hiredate)a) b
 WHERE a.rn-1 = b.rn(+)
 ORDER BY a.sal DESC, a.hiredate;
 --연결이 실패하더라도 나오게함 = outer join (null값이 나와야하는 부분에 (+))
 
 --실습 ana6
 분석함수을 이용하여 모든 사원에 대해 사원번호, 사원이름, 입사일자, 직군, 급여 정보와 담당업무별 급여순위가 1단계 높은 사람의
 급여를 조회하는 쿼리 작성 (급여가 같을 경우 입사일이 빠른 사람이 높은 순위)
 
 SELECT empno, ename, job, hiredate, sal,
        LAG(sal) OVER (PARTITION BY job ORDER BY sal DESC, hiredate) lag_sal
FROM emp;

분석함수 OVER([] [] []) 

LAG, LEAD 함수의 두번째 인자 : 이전, 이후 몇번째 행을 가져올지 표기 (행의 수 조절가능)
 SELECT empno, ename, hiredate, sal,
        LAG(sal, 2/*두칸씩 밀림 */) OVER (ORDER BY sal DESC, hiredate) lag_sal
FROM emp;

 SELECT empno, ename, hiredate, sal,
        LEAD(sal, 2) OVER (ORDER BY sal DESC, hiredate) lag_sal
FROM emp;

no_ana3
분석함수 없이 모든 사원에 대해 사원번호, 사원이름, 입사일자, 급여를 급여가 낮은순으로 조회해보자
급여가 동일할 경우 사원번호가 빠른 사람이 우선순위

힌트: rownum, 범위조인
SELECT a.empno, a.ename, a.sal, SUM(b.sal)
FROM
(select a.*, ROWNUM rn
FROM 
(select empno, ename, sal
from emp
order by sal ASC, empno)a)a,

(select a.*, ROWNUM rn
FROM 
(select empno, ename, sal
from emp
order by sal ASC, empno)a) b
WHERE a.rn >=  b.rn
GROUP BY a.empno, a.ename, a.sal
ORDER BY a.sal, a.empno;

rownum/ 인라인뷰 / 범위join (non-equi-join) / GROUP BY 

분석함수 OVER([PARTITION BY] [ORDER BY] [WINDOWING])
windowing
: 윈도우 함수의 대상이 되는 행을 지정 (행들의 범위)
UNBOUNDED PRECEDING : 특정 행을 기준으로 모든 이전행 (LAG)
   n  PRECEDING     : 특정행을 기준으로 N행 이전행(LAG)
CURRENT ROW : 현재행
UNBOUNDED FOLLOWING : 특정 행을 기준으로 모든 이후행 (LEAD)
    n  FOLLOWING    : 특정 행을 기준으로 N행 이후행 (LEAD)
    
분석함수 OVER([PARTITION BY] [ORDER BY] [WINDOWING])  --partitino 이 빠짐    
select empno, ename, sal,
        SUM(sal) OVER (ORDER BY sal, empno ROWS BETWEEN /*(이전에 등장하는 모든행부터 나까지)*/ UNBOUNDED PRECEDING AND CURRENT ROW) c_sum
        SUM(sal) OVER (ORDER BY sal, empno ROWS UNBOUNDED PRECEDING ) c_sum --현재행까지 기본값으로 되어있기때문에 위에와 같음
FROM emp
ORDER BY sal, empno;

select empno, ename, sal,
        SUM(sal) OVER (ORDER BY sal, empno ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) c_sum -- 자신보다 1이전부터 1이후 
FROM emp
ORDER BY sal, empno;

--ana 7
사원번호, 사원이름, 부서번호, 급여 정보를 부서별로 급여, 사원번호 오름차순으로 정렬했을때, 자신의 급여와 선행하는 사원들의 급여 합을 조회하는 쿼리 작성 (분석함수 사용)

select empno, ename, deptno, sal, SUM(sal) OVER (PARTITION BY deptno ORDER BY sal, empno ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) c_sum
from emp;

--참고
범위설정 
rows  : 물리적인 row  (오로지 자신까지만)
range  : 논리적인 값의 범위 / 같은 값을 하나로 본다

rows 와 range의 차이
select empno, ename, deptno, sal,
        SUM(sal) OVER (ORDER BY sal ROWS UNBOUNDED PRECEDING) rows_c_sum,
        SUM(sal) OVER (ORDER BY sal RANGE UNBOUNDED PRECEDING) range_c_sum,
        SUM(sal) OVER (ORDER BY sal) no_win_c_sum,  --기본 윈도윙이 들어가있으므로 위에와 동일하게 나옴 (order by 가 있어야지 windowing 사용가능 없을 시 전체 합이나옴)
        SUM(sal) OVER () no_ord_c_sum --order by가 없으므로 전체합이 나옴
from emp;