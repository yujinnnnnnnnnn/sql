FROM -> (START WITH) ->WHERE -> GROUP BY -> SELECT -> ORDER BY  
         --WHERE 절 전에
SELECT 
FROM
WHERE
START WITH
CONNECT BY
GROUP BY
ORDER BY

가치치기: Pruning brunch

select empno, LPAD(' ', (LEVEL -1)*4)|| ename ename, mgr, deptno, job
from emp
--where job != 'ANALYST' -- 계층쿼리가 완성된 다음 행제한
start with mgr is null
connect by prior empno = mgr AND job != 'ANALYST'; --계층쿼리를 만들면서 조건을 만족

계층 쿼리와 관련된 특수 함수
1. connect_by_root (컬럼) : 최상위 노드의 해당 컬럼 값
2. SYS_CONNECT_BY_PATH (컬럼, '구분자문자열') : 최상위 행부터 현재 행까지의 해당 컬럼의 값을 구분자로 연결한 문자열(어떻게 값을 타고왔는지 알수 있음)
3. CONNECT_BY_ISLEAF : CHILD가 없는 leaf node 여부 0 (false) no leaf node /1 (true) leaf node 
select LPAD(' ', (LEVEL -1)*4)|| ename ename,
        CONNECT_BY_ROOT (ename) root_ename,
        LTRIM(SYS_CONNECT_BY_PATH(ename,'-'), '-') path_ename, --LTRIM 사용이유 : 맨왼쪽 '-'지우기 위해
        CONNECT_BY_ISLEAF isleaf
from emp
start with mgr is null
connect by prior empno = mgr;

<게시판은 루트가 많음>
1.제목
  --2.답글
3.제목 

--특정 문자열 제거
--  INSTR('TEST', 'T'),
--  INSTR('TEST', 'T', 2)

--계층쿼리 실습H 9
최상위글은 최신글이 먼저 오고, 답글의 경우 작성한 순서대로 정렬됨
어떻게 하면 최상위글은 최신글(desc)로 정렬하고, 답글은 순차(asc)적으로 정렬할 수 있을까?
시작(ROOT)글은 작성 순서의 역순으로
답글은 작성 순서대로 정렬
select gn, seq, parent_seq, LPAD(' ', (LEVEL-1)*4) || title title
from board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY gn DESC, seq ASC; 
 --계층구조를 유지하면서 정렬

--다른 방법
select *
from
    (select CONNECT_BY_ROOT(seq) root_seq,  --gn 과 동일하지만 order by와 CONNECT_BY_ROOT을 같이쓸수 없기때문에 알리아스를 주고 order by에 써줌
        seq, parent_seq, LPAD(' ', (LEVEL-1)*4) || title title
    from board_test
    START WITH parent_seq IS NULL
    CONNECT BY PRIOR seq = parent_seq)
    ORDER BY root_seq DESC, seq ASC;
--???인라인뷰를 한이유

--정확한 답
select *
from
    (select CONNECT_BY_ROOT(seq) root_seq,  
        seq, parent_seq, LPAD(' ', (LEVEL-1)*4) || title title
    from board_test
    START WITH parent_seq IS NULL
    CONNECT BY PRIOR seq = parent_seq)
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY root_seq DESC, seq ASC;


시작글부터관련 답글까지 그룹번호를부여하기 위해 새로운 컬럼 추가하기

ALTER TABLE board_test ADD(gn NUMBER);
DESC board_test;

UPDATE board_test SET gn = 1
WHERE seq IN (1, 9);

UPDATE board_test SET gn = 2
WHERE seq IN (2, 3);

UPDATE board_test SET gn = 4
WHERE seq NOT IN (1, 2, 3, 9);

commit;


---페이징 처리
pageSize : 5
page : 2
select *
from
(select ROWNUM rn, a.*
 from
  (select gn, seq, parent_seq, LPAD(' ', (LEVEL-1)*4) || title title
    from board_test
    START WITH parent_seq IS NULL
    CONNECT BY PRIOR seq = parent_seq
    ORDER SIBLINGS BY gn DESC, seq ASC)a)
where rn between 6 and 10;    

--비상호
select *
from emp
where deptno= 10 
  and sal = (select MAX(sal)
             from emp
             where deptno = 10);
             
분석함수(windw 함수) (쿼리를 짧게 할 수 있음)
    SQL에서 행간 연산을 지원하는 함수
    
    해당 행의 범위를 넘어서 다른 행과 연산이 가능
    .SQL의 약점 보안
    . 이전행의 특정컬럼을 참조
    . 특정범위의 행들의 컬럼의 합
    . 특정 범위의 행중 특정 컬럼을 기준으로 순위, 행번호 부여
    
    . SUM, COUNT,AVG, MAX, MIN
    . RANK, LEAD, LAG....
    
    PARTITION BY
-분석함수 도전 실습 ana0
사원의 부서별 급여(sal) 별 순위 구하기

--분석함수 사용안하고 쿼리작성
SELECT ename, a.sal, a.deptno, b.rank 
FROM
(SELECT a.*, ROWNUM rn
FROM
(SELECT ename, sal, deptno
FROM emp
ORDER BY deptno, sal DESC)a )a,

(SELECT ROWNUM rn, rank
FROM
(SELECT a.rn rank
FROM
    (SELECT ROWNUM rn
    FROM emp) a,

    (SELECT deptno, COUNT(*) cnt
    FROM emp
    GROUP BY deptno
    ORDER BY deptno) b
WHERE a.rn <= b.cnt
ORDER BY b.deptno, a.rn)) b
WHERE a.rn = b.rn;


SELECT ename, sal, deptno, RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_rank
FROM emp
--ORDER BY deptno, sal DESC;  이미 분석함수에서 정렬했기때문에 사용안해도 됨
PARTITION BY : deptno 같은 부서코드를 갖는 row를 그룹을 묶는다
ORDER BY sal : 그룹내에서 sal로 row의 순서를정한다
RANK() :파티션 단위안에서 정렬 순서대로 순위 부여

순위 관련된 함수 (중복값을 어떻게 처리하는가)
RANK : 동일값에 대해 동일 순위 부여, 후순위는 동일값만큼 건너뛴다
    1등2등이면 그 다음 순위는 3위
    
DENSE_RANK : 동일 값에대해 동일 순위 부여, 후순위는 이어서 부여
    1등2등이면 그 다음 순위는 2위 
    
ROW_NUMBER : 중복없이 행에 순차적인 번호를 부여(ROWNUM)

SELECT ename, sal, deptno,
        RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_rank,
        DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_dense_rank,
        ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_row_number
FROM emp;

SELECT WINDOW_FUCNTION([인자]) OVER([PARTITION BY 컬럼][ORDER BY 컬럼])
FROM ....

PARTITION BY : 영역 설정
ORDER BY (ASC/DESC): 영역 안에서의 **순서 정하기**

--실습 ANA1
사원 전체급여 순위를 rank, dense_rank, row_number를 이용하여 구하세요 --전체행을 기준으로 사용하므로 partition by를 사용하지 않음
단 급여가 동일할 경우 사번이 빠른 사람이 높은 순위가 되도록 작성

select empno, ename, sal, deptno, 
        RANK() OVER (ORDER BY sal DESC, empno) sal_rank,
        DENSE_RANK() OVER (ORDER BY sal DESC, empno) sal_dense_rank,
        ROW_NUMBER() OVER (ORDER BY sal DESC, empno) sal_row_number
from emp
 
 --실습 no_ana2
 기존의 배운 내용을 활용하여, 모든 사원에 대해 사원번호, 사원이름, 해당 사원이 속한 부서의 사원 수를 조회하는 쿼리
select emp.empno, emp.ename, emp.deptno, b.cnt
from emp,
 (select deptno, count(deptno) cnt
 from emp
 group by deptno)b
 where emp.deptno = b.deptno
 order by emp.deptno;
 
 --분석함수 사용
SELECT empno, ename, deptno,
        COUNT(*) OVER (PARTITION BY deptno) cnt
FROM emp;