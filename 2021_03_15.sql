2021-03-12 복습
★ WHERE 절 조건 비교 - 기술한 조건을 참으로 만족하는 행들만 조회됨
DML -CRUD 

--row : 14, col : 8개
-- 컬럼정보 보는 법
--컬럼명만 보는 법
SELECT *
FROM emp
where 1 =1;

--30을 가진 행들만 조회
SELECT *
FROM emp
WHERE deptno = 30;

SELECT *
FROM emp
WHERE deptno = deptno;
--해당행의 부서번호와 해당행의 부서번호가 같으면 조회 => 14개 조회됨

--!=은 모두 거짓이므로 조회가 안됨
SELECT *
FROM emp
WHERE deptno != deptno;

NULL을 포함한 열은 무조건 NULL이다.

--<<<<<리터널>>>>
--숫자표현
int a = 20;
--문자열 
String a ='';

--문자열 결합 
 java = +
 oracle = ||
 
SELECT 'SELECT * FROM ' || table_name || ';'
FROM user_tables;

--날짜
'81/03/01' 
TO_DATE('81/03/01', 'YY/MM/DD')

--입사일자가 1982년 1월 1일 이후인 모든 직원 조회하는 select 쿼리 작성
--(컬럼명)      (상수)
--숫자 비교 : 30 > 20
--날짜에도 대소비교가능 : 2021-03-15 > 2021-03-12

SELECT *
FROM emp
WHERE hiredate >= TO_DATE('1982/01/01', 'YYYY/MM/DD'); 

<<<WHERE 절에서 사용 가능한 연산자>>>
(비교 연산자 배움 (= , !=, >, <, ...))

몇항이 필요한지 생각해야함
a + b -- +는 피연산자가 2개가 필요한 이항연산자
--? 는 삼항연산자
a++ == a = a + 1;
++a == a = a + 1;

<<<<<<<<<<<<BETWEEN AND -- 삼항연산자 >>>>>>>>>>>>

조건에 맞는 데이터 조회하기 (BETWEN)
<<<<WHERE 1>>>>

*emp 테이블에서 입사 일자가 1982년 1월1일 이후부터 1983년 1월 1일 이전인 사원의 ename, hiredate 데이터를 조회하는 쿼리를 작성하시오.
SELECT *
From emp
WHERE hiredate BETWEEN TO_DATE('19820101', 'YYYYMMDD') AND TO_DATE('19830301', 'YYYYMMDD');

<<<<<<<<WHERE2>>>>>>>>>>
SELECT *
From emp
WHERE hiredate >= TO_DATE('19820101' , 'YYYYMMDD')
    AND hiredate <= TO_DATE('19830301' , 'YYYYMMDD');
   
BETWEEN AND : 포함 (이상,이하)
              초과, 미만의 개념을 적용하려면 비교연산자 사용해야 함
              
<<<<<<<<<<<<IN 연산자>>>>>>>>>>>>>
대상자 IN (대상자와 비교할 값 1, 대상자오 ㅏ비교할 값2,...) --or 의개념
deptno IN (10, 20) => deptno 값이 10이나 20번이면 TRUE;

SELECT *
FROM emp
WHERE deptno = 10
     OR deptno = 20;
     
SELECT *
FROM emp
WHERE 10 IN (10,20);
-- => 10은 10과 같거나 20과 같다
    TRUE    or       false
    
    조건에 맞는 데이터 조회하기 (IN)
    
    user 테이블에서 userid 가 brown, cony, sally인 데이터를 다음고 ㅏ같이 조회 하시오
    
    SELECT userid AS 아이디, usernm AS 이름, alias AS 별명
    FROM users
    WHERE userid IN ('brown', 'cony' , 'sally');
    
    SELECT *
    FROM emp
    WHERE userid = 'brown' OR 'cony' OR 'sally';

--우선 모든 컬럼 조회 해야함

<<<<<<<<<<<<<<LIKE  연산자 : 문자열 매칭 조회>>>>>>>>>>>>>>
게시글 : 제목검색, 내용검색
        제목에 맥북에어가 들어가느 게시글만 조회
        
        1. 얼마 안된 맥북에어 팔아요
        2. 맥북에어 팔아요
        3. 팔아요 맥북에어
 테이블 : 게시글
 제목 컬림 : 제목
 
 SELECT *
 FROM 게시글
 WHERE 제목 LIKE '%맥북에어%'
    OR 내용 LIKE '%맥북에어%' ;

     제목       내용
      1          2
    TRUE   OR    TRUE         => TRUE
    TURE   OR    FALSE        => TRUE   
    FALSE  OR    TRUE         => FALSE
    FALSE  OR    FALSE        => FALSE
 
     제목       내용
      1          2
    TRUE   AND    TRUE         => TRUE
    TURE   AND   FALSE        => FALSE   
    FALSE  AND   TRUE         => FALSE
    FALSE  AND   FALSE        => FALSE
    
% : 0개 이상의 문자 
_ : 1개의 문자

'%l%' : l문자열의 앞, 뒤 부분이 0개거나, 여러개 와도 됨 
c로 시작하는 아이디 조회 -> c% (c뒤에 0개 이상의 문자가 옴)
SELECT *
FROM users
WHERE userid LIKE 'c%'; -- 2항

userid 가 c로 시작하면서 c이후에 3개의 글자가 오는 사용자

SELECT *
FROM users
WHERE userid LIKE 'c___';
 
 
userid에 l이 들어가는 모든 사용자 조회
SELECT *
FROM users
WHERE userid LIKE '%l%';
<<<<<<<<<WHERE 4>>>>>>>>
member 테이블에서 회원의 성이 [신]씨인 사람의 mem_id, mem_name을 조회하는 쿼리 작성

SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '신%';

<<<<<<<<WHERE 5>>>>>>>>>>
member 테이블에서 회원의 이름에 글자 [이]가 들어가는 모든 사람의 mem_id, mem_name을 조회하는 쿼리 작성

SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '%이%';


<<<<<<<<<<<IS (NULL 비교) ( '=' 연산자 사용 X )>>>>>>>>>>> -- UNLL은 값을 모르는 행을 의미
<<<<<<<WHERE 6>>>>>>>>>
comm 테이블에서 sal컬럼의 값이 NULL인 사람만 조회

SELECT *
FROM emp
WHERE comm IS (NOT) NULL;
        sal = 1000
        sal != 1000
        
emp 테이블에서 매니저가 없는 직원만 조회
SELECT *
FROM emp
WHERE mgr IS NULL;

BETWEEN AND, IN, LIKE, IS

논리 연산자 : AND, OR, NOT
AND : 두가지 조건을 동시에 만족 시키는지 확인할 때
    조건 1 AND 조건 2
OR : 두가지 조건중 하나라도 만족 시키는지 확인할 때
    조건 1 OR 조건 2
NOT : 부정형 논리연산자, 특정 조건을 부정
    mgr IS NULL : mgr 컬럼의 값이 NULL인 사람만 조회

emp  테이블에서 mgr 의 사번이 7698이면서 sal 값이 1000보다 큰 직원만 조회
-- 조건의 순서는 결과와 무관하다
SELECT *
FROM emp
WHERE mgr = 7698
     AND sal > 1000; --(mgr과 sal위치를 바꿔도 동일함)
     
--sal 컬럼의 값이 1000보다 크거나 mgr의 사번이7698인 직원조회
SELECT *
FROM emp
WHERE mgr = 7698
     OR sal > 1000;
     
AND 조건이 많아지면 : 조회되는 데이터 건수는 줄어든다
OR 조건이 많아지면 : 조회되는 데이터 건수는 많아진다

NOT : 부정형 연산자, 다른 연산자와 결합하여 쓰인다
        IS NOT, NOT IN, NOT LIKE

--직원의 부서번호가 30번이 아닌 직원들
SELECT *
FROM emp
WHERE deptno NOT IN (30);

SELECT *
FROM emp
WHERE deptno != (30);

SELECT *
FROM emp
WHERE ename NOT LIKE 'S%';

<<<<<<<★ NOT IN 연산자 사용 시 주의사항: 비교값주에 NULL이 포함되면>>>>>
                                    데이터가 조회되지 않는다(시험에 출제됨)


SELECT *
FROM emp
WHERE mgr IN (7698, 7839, NULL);
==> 
mgr = 7698 OR mgr = 7839 OR mgr = NULL 


SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839, NULL);
 !(mgr = 7698 OR mgr = 7839 OR mgr = NULL)
==> mgr != 7698 AND mgr != 7839 AND mgr != NULL
        TRUE FALSE 의미가 없음 AND FALSE

mgr = 7698 ==> mgr != 7698
OR        ==> AND

<<<<<<<WHERE 7>>>>>>>>>>
emp 테이블에서 job 이 SALESMAN이고 입사일자가 1981 6 1일 이후인 직원의 정보를 다음과 같이 조회

SELECT *
FROM emp
WHERE hiredate >= TO_DATE('19810601', 'YYYYMMDD') AND job = 'SALESMAN';

<<<<<<<<<<where 8, 9>>>>>>>>>
emp 테이블에서 부서번호가 10번이 아니고 입사일자가 1981 6 1 이후인 직원인 정보를 다음과 같이 조회
(in not in 금지)
SELECT *
FROM emp
WHERE hiredate >= TO_DATE('1981/06/01', 'YYYY/MM/DD')
                AND deptno != 10; -- deptno NOT IN <==(10)emp 테이블에서 부서번호가 10번이 아니고 입사일자가 1981 6 1 이후인 직원인 정보를 다음과 같이 조회
 
 <<<<<<<<<<<WHERE 10>>>>>>>>               
emp 테이블에서 부서번호과 10번이 아니고 입사일자가 1981 6 1일 이후인 직원의 정보를 다음고 ㅏ같이 조회
부서는 10 20 30 만 있다고 가정하고 in 연산자 사용
SELECT *
FROM emp
WHERE deptno NOT IN (10)-- deptnO IN (20, 30)
        AND hiredate >= TO_DATE('19810601','YYYYMMDD');
        
 <<<<<<<<<<WHERE 11>>>>>>>>>       
emp 테이블에서 job이 SALESMAN이거나 입사일자가 1981 06 1 이후인 직원의 정보 다음과 조회
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR hiredate >= TO_DATE('19810601','YYYYMMDD');

<<<<<WHERE 12풀면좋고 안풀어도 괜춘>>>>>>>>>>

emp 테이블에서 job이 SALESMAN 이거나 사원번호가 78로 시작하는 직원의 정보를 다음고 ㅏ같이 조회
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR EMPNO LIKE '78%'; 
--EMPNO 컬럼 타입은 숫자 하지만  LIKE ''은 문자열매칭을 사용함 => EMPNO의 숫자가 암묵적으로 문자로 바뀜(자동 형변환)


데이터 타입에 대해 고민, empno컬럼에 들어갈 데이터 파일 크기 생각하면서 풀기
emp 테이블에서 job이 SALESMAN 이거나 사원번호가 78로 시작하는 직원의 정보를 다음고 ㅏ같이 조회
(LIKE 쓰지말고 사용)

SELECT *
FROM emp
WHERE job = 'SALESMAN' OR EMPNO = '7839' AND '7844' AND '7876';





