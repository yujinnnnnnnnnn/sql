연산자 우선순위
1. 산술 연산자
2. 문자열 결합
3. 비교 연산
4. IS, [NOT] NULL, LIKE, [NOT] IN
5. [NOT]BETWEEN
6. NOT
7. AND
8. OR

연산자 우선순위 (AND가 OR보다 우선순위가 높다)
==> 헷갈리면 ()를 사용하여 우선순위를 조정하자

SELECT *
FROM emp
WHERE ename = 'SMITH' OR (ename = 'ALLEN' AND job = 'SALESMAN');
--직원의 이름이 ALLEN이면서 job이 SALESMAN이거나
--직원의 이름이 SMITH인 직원 정보를 조회

--직원의 이름이 ALLEN이거나 SMITH이면서 
--job이 SALESMAN인 직원 정보를 조회

SELECT *
FROM emp
WHERE (ename = 'SMITH' OR ename = 'ALLEN') AND job = 'SALESMAN';

where14
emp테이블에서
1.job이 SALESMAN 이거나
2. 사원번호가 78로 시작하면서 입사일자가 1981년 6월 1일 이후인 직원의 정보를 다음과 같이 조회하세요
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR empno LIKE '78%' AND hiredate >= TO_DATE('1981/06/01', 'YYYY/MM/DD');

데이터 정렬
-TABLE 객체에는 데이터를 저장/ 조회시 순서를 보장하지 않음
-보편적으로 데이터가 입력된 순서대로 조회됨
-데이터가 항상 동일한 순서로 조회되는 것을 보장하지 않는다
-데이터가 삭제되고, 다른 데이터가 들어 올 수도 있음

okjsp->okky
jsp ==> java server page

데이터 정렬(ORDER BY) 
ORDER BY
ASC : 오름차순(기본)
DESC : 내림차순
ORDER BY {정렬기준 컬럼 OR alias OR 컬럼번호}[ASC OR DESC]...

데이터 정렬이 필요한 이유 ? 
1. table 객체는 순서를 보장하지 않는다
==>오늘 실행한 쿼리를 내일 실행할 경우 동일한 순서로 조회가 되지 않을 수도 있다
2. 현실세계에서는 정렬된 데이터가 필요한 경우가 있다
==>게시판의 게시글은 보편적으로 가장 최신글이 처음에 나오고, 가장 오래된 글이 맨 밑에 있다

SQL 에서 정렬: ORDER BY ==> SELECT -> FROM -> [WHERE] -> ORDER BY
정렬 방법 : ORDER BY 컬럼명 | 컬럼 인덱스 (순서) | 별칭 | [정렬 순서]
정렬 순서 : 기본 ASC(오름차순, DESC(내림차순)

SELECT *
FROM emp
ORDER BY job DESC, sal ASC, ename;
A -> B -> C -> [D] -> Z
1 -> 2 -> ... -> 100 오름차순 (ASC => DEFAULT) 생략가능
100 -> 99 -> ... ->1 내림차순 (DESC => 명시) --DESCRIBE랑은 다름

정렬 : 컬럼명이 아니라 select 절의 컬럼 순서(index)
SELECT ename, empno, job, magr AS m
FROM emp
ORDER BY m;  --ORDER BY 2 => 좋지 않음

데이터 정렬 (ORDER BY 실습 orderby 1)
-dept 테이블의 모든 정보를 부서이름으로 오름차순 정렬 로 조회되도록 쿼리를 작성하세요
-dept테이블의 모든 정보를 부서위치로 내림차순 정렬로 조회되도록 쿼리를 작성하세요

SELECT *
FROM dept
ORDER BY dname ASC;

SELECT *
FROM dept
ORDER BY loc DESC;

orderby2
emp테이블에서 상여정보(comm)가 있는 사람들만 조회하고, 
상여(comm)를 많이 받는 사람이 먼저 조회되도록 정렬하고,
상여가 같을 경우 사번으로 내림차순 정렬하세요 (상여가 0인 사람은 상여가 없는 것으로 간주)

SELECT *
FROM emp
WHERE comm IS NOT NULL 
    AND comm != 0
ORDER BY comm DESC, empno DESC;

orderby3
emp 테이블에서 관리자가 있는 사람들만 조회하고, 직군(job) 순으로 오름차순 정렬하고, 직군이 같을 경우
사번이 큰 사원이 먼저 조회되도록 쿼리를 작성하세요
SELECT *
FROM emp
WHERE mgr IS NOT NULL
ORDER BY job, empno DESC;

orderby4
emp 테이블에서 10번 부서 혹은 30번 부서(deptno)에 속하는 사람 중 급여(sal)가 1500이 넘는 사람들만 조회하고
이름으로 내림차순 정렬되도록 쿼리를 작성하세요
SELECT *
FROM emp
WHERE deptno IN(10, 30)  --deptno = 10 OR deptno = 30
    AND sal >1500    
ORDER BY ename DESC;

----------------------------------------------------------------------------------------------------

페이징 처리(게시글) ==> 정렬의 기준이 뭔데?? (일반적으로는 게시글의 작성일시 역순) **무조건 써야함 (중요)

페이징 처리 : 전체 데이터를 조회하는 게 아니라 페이지 사이즈가 정해졌을 때 원하는 페이지의 데이터만 가져오는 방법
(1. 400건을 다 조회하고 필요한 20건만 사용하는 방법 --> 전체조회(400)
 2. 400건의 데이터중 원하는 페이지의 20건만 조회 --> 페이징 처리(20) )
 
 페이징 처리시 고려할 변수 : 페이지 번호(몇번째 페이지), 페이지 사이즈(한페이지 당 몇개씩)
 
 ROWNUM: 행번호를 부여하는 특수 키워드(오라클에서만 제공)
        *제약사항 : ROWNUM은 WHERE절에서도 사용가능하다
        단 ROWNUM의 사용을 1부터 사용하는 경우에만 사용가능 
        WHERE ROWNUM BETWEEN 1 AND 5; ==> O
        WHERE ROWNUM BETWEEN 6 AND 10; ==> X
        WHERE ROWNUM = 1; ==> O
        WHERE ROWNUM = 2; ==> X
        WHERE ROWNUM <[=] 10; ==> O 1부터 10까지 읽는 거니까 됨
        WHERE ROWNUM > 10; ==> X 10보다 큰거부터니까 안됨
        전체 데이터 : 14건
        페이지 사이즈 : 5건
        1번째 페이지 : 1 ~ 5 
        2번째 페이지 : 6 ~ 10
        3번째 페이지 : 11 ~ 15 (14)
        
        SQL 절은 다음의 순서로 실행된다
        FROM => WHERE => SELECT => ORDER BY
        ORDER BY와 ROWNUM을 동시에 사용하면 정렬된 기준으로 ROWNUM이 부여되지 않는다
        (SELECT 절이 먼저 실행되므로 ROWNUM이 부여된 상태에서 ORDER BY절에 의해 정렬이 된다)
        
        
 인라인 뷰 : 테이블을 임의로 만드는 것
 ALIAS
 
 SELECT empno, ename
 FROM emp;
1-14번의 행번호를 컬럼으로 부여할 수 없을까? --ROWNUM 사용
SELECT ROWNUM, empno, ename 
FROM emp
WHERE ROWNUM BETWEEN 1 AND 5;
1 AND 5는 되는데 6~ 안됨

SELECT ROWNUM, empno, ename 
FROM emp
WHERE ROWNUM <= 15; --가능함(1부터 15까지)

-------------------------------두개 비교할 줄 알아야함--------------------------------------------
SELECT ROWNUM, empno, ename 
FROM emp
ORDER BY ename;

--1) 인라인 뷰로 만들어 조회하기 ORDER BY를 먼저 하기 위해
SELECT ROWNUM, empno, ename  --job을 조회하면 오류뜸 (empno, ename만 존재함)
FROM (SELECT empno, ename 
      FROM emp
      ORDER BY ename); 

--2) 한번 더 인라인 뷰로 만들기 별칭 지정해준 후 WHERE해야 rn 사용 가능
ROWNUM으로만 쓰면 첫줄 SELECT절의 ROWNUM이 되기 때문에 6 AND 10 실행안됨
SELECT *
FROM (SELECT ROWNUM rn, empno, ename  
      FROM (SELECT empno, ename 
      FROM emp
      ORDER BY ename))
WHERE rn BETWEEN 6 AND 10;

SELECT *
FROM (SELECT ROWNUM rn, empno, ename  
      FROM (SELECT empno, ename 
      FROM emp
      ORDER BY ename))
WHERE rn BETWEEN (:page -1)*:pageSize + 1 AND :page*:pageSize; --:붙이면 ==> 변수 됨
바인드 입력 창 ==> pageSize : 5, page : 1 ==> 1,2,3,4,5
바인드 입력 창 ==> pageSize : 5, page : 2 ==> 6,7,8,9,10
바인드 입력 창 ==> pageSize : 5, page : 3 ==> 11,12,13,14


pageSize : 5건
1 page : rn BETWEEN 1 AND 5;
2 page rn BETWEEN 6 AND 10;
3 page : rn BETWEEN 11 AND 15;
n page : rn BETWEEN (n-1) * pageSize + 1 AND n*5; --n*5-4
1) n*pageSize-(pageSize-1)
2) n*pageSize- pageSize +1
3) (n-1) * pageSize + 1


SELECT *
FROM (SELECT ROWNUM rn, empno, ename  
      FROM (SELECT empno, ename 
      FROM emp
      ORDER BY ename))
WHERE rn BETWEEN 11 AND 15;
-----------------------------------------------------------------------------------------------
데이터 정렬(가상 컬럼 ROWNUM 실습 row_1)
emp 테이블에서 ROWNUM 값이 1~10인 값만 조회하는 쿼리를 작성해보세요 (정렬없이 진행하세요, 결과는 화면과 다를 수 있습니다)
//정렬이 없어서 결과화면 달라짐
SELECT ROWNUM rn, empno, ename
FROM emp
WHERE ROWNUM BETWEEN 1 AND 10;

row_2
ROWNUM 값이 11~20(11~14)인 값만 조회하는 쿼리를 작성해보세요

SELECT *
FROM(SELECT ROWNUM rn, empno, ename
     FROM emp)
WHERE rn BETWEEN 11 AND 14;

row_3
emp 테이블의 사원 정보를 이름 컬럼으로 오름차순 적용했을 때의 11~14번째 행을 다음과 같이 조회하는 쿼리를 작성해보세요
SELECT a.*
FROM(SELECT ROWNUM rn, empno, ename
FROM(SELECT empno, ename
FROM emp
ORDER BY ename))a
WHERE rn BETWEEN 11 AND 14;

SELECT ROWNUM rn, emp.* --한정자  emp. 붙여줘야함
FROM emp e; --테이블에서도 다른 이름으로 바꿀 수는 있는데 AS e라고 못씀
===> 오류뜸

SELECT ROWNUM rn, e.* --테이블 이름이 e로 변경됐으니까 emp.을 SELECT절을 e.으로 변경해줘야함
FROM emp e;
==> 오류 해결

SELECT ROWNUM rn, e.*
FROM emp e, emp m;

