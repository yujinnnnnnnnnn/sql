INSERT 한건, 여러건

UPDATE 테이블명 SET 컬럼명1 = 값

서브쿼리를 이용해서 업데이트 가능 / 값이 SELECT쿼리의 값으로 대체가능 BUT 행이 하나여야함
UPDATE 테이블명 SET 컬럼명1 = (스칼라 서브쿼리),
                   컬럼명 2  = (스칼라 서브쿼리),

INSERT INTO 테이블명
SELECT ....

999사번 ( EMPNO)을 갖는  brown 직원(ename)을 입력
INSERT INTO emp(empno, ename) VALUES (9999, 'brown');
INSERT INTO emp(empno, ename) VALUES ('brown', 9999);

DESC emp;

select*
from emp;

9999번 직원의 deptno 와 job 정보를 smith 사원의 deptno, job 정보로 업데이트

select deptno, job
from emp
where ename = 'SMITH';

update emp set deptno =(select deptno
                        from emp
                        where ename = 'SMITH'),
                job = (select job
                       from emp
                       where ename = 'SMITH')
where empno = 9999;

select *
from emp
where empno = 9999;

DELETE : 기존에 존재하는 데이터를 삭제
DELETE 테이블명
WHERE 조건;

DELETE 테이블명 -- 테이브명의 모든 행들을 지우는것

삭제 테스트를 위한 데이터 입력
INSERT INTO emp(empno, ename) VALUES (9999, 'brown');
DELETE emp
where empno = 9999;

mgr 가 7698사번(BLAKE) 인 직원들 모두 삭제
select *
from emp
WHERE mgr = 7698;

--서브쿼리방법
-- 셀렉절 먼저 하는 법 익숙해지기
select *
from emp
WHERE empno IN (SELECT empno
                FROM emp
                WHERE mgr = 7698);

DELETE emp
WHERE empno IN (SELECT empno
                FROM emp
                WHERE mgr = 7698);

ROLLBACK;

DBMS는 DML 문장을 실행하게 되면 LOG를 남긴다
    UND(REDO) LOG
    
로그를 남기지 않고  더 빠르게 데이터 삭제하는 방법 : TRUNCATE
 .DDL
 .DML이 아니기때문에 ROLLBACK 불가(복구 불가)
 .주로 테스트 환경에서 사용
 
CREATE TABLE emp_test AS
SELECT *
FROM emp;

select *
from emp_test;

Truncate table emp_test;

ROLLBACK;

트랜잭션 : 논리적인 일의 단위
 .첫번째 DML문을 실행함과 동시에 트랜잭션 시작
 .이후 다른 DML문 실행
 commit : 트랜잭션을 종료, 데이터를 확정
 rollback : 트랜잭션에서 실행한 DML문을 취소하고 트랜잭션 종료
 
 트랜잭션 예시
 . 게시글 입력시 (제목, 내용, 복수개의 첨부파일)
 .게시글 테이블, 게시글 첨부파일 테이블
 .1.DML : 게시글 입력
 .2.DML : 게시글 첨부파일입력
 .1번 DML은 정상적으로 실행후 2번 DML 이 에러가 발생한다면?
 
 DML/DDL
 .자동 commit(묵시적 commit)
 .rollback 불가
 
 읽기 일관성 레벨 (0 -> 3)
 트랜잭션에서 시행한 결과가 다른 트랜잭션에 어떻게 영향을 미치는지 
 정의한 레벨(단계)
 
 LEVEL 0 : READ UNCOMMINTED
 . dirty (변경이 가해졌다) read
 .커밋을 하지 않은 변경 사항도 다른 트랜잭션에서 확인 가능
 .oracle에서는 지원하지 않음
 
 LEVEL 1 : READ COMMITED
 . 대부분의 DBMS 읽기 일관성 설정 레빌
 . 커밋한 데이터만 다른 트랜잭션에서 읽을 수 있다
   커밋하지 않은 데이터는 다른 트랜잭션에서 볼 수 없다.
   
 LEVEL 2 : Reapeatalbe Read
 . 선행 트랜잭션에서 읽은 데이터를
   후행 트랜잭션에서 수정하지 못하도록 방지
 . 선행 트랜잭션에서 읽었던 데이터를
   트랜잭션의 마지막에서 다시 조회를 해도 동일한 결과가 나오게끔 유지
   
 . 신규 입력 데이터에 대해서는 막을 수 없음
 => Phantom Read (유령 읽기) -- 없던 데이터가 조회 되는 현상
 
 기존 데이터에 대해서는 동일한 데이터가 조회되도록 유지
 . orcale 에서는 LEVEL 2에 대해 공식적으로 지원하지 않으나
   FOR UPDATE 구문을 이용하여 효과를 만들어 낼 수 있다.
   
 LEVEL 3 : Serializable Read
 . 후행 트랜잭션에서 수정, 입력, 삭제한 데이터가 선행 트랜잭션에 영향을 주지 않음
 . 선 : 데이터 조회(14)
 . 후 : 신규에 입력 (15)
 . 선 : 데이터 조회 (14)
   
   
 인덱스
 . 눈에 보이지 않음
 . **테이블의 일부 컬럼을 사용하여 데이터를 정렬한 객체 --인덱스를 만든다는 것은 어떤 테이블에 만든다는 뜻 (테이블과 인덱스는 항상 같이 있음)
   ==> 원하는 데이터를 빠르게 찾을 수 있다.
 . 일부 컬럼과 함께 그 컬럼의 행을 찾을 수 있는 ROWID 가 같이 저장됨
 . ROWID :테이블에 저장된 **행의 물리적 위치, 집 주소 같은 개념
          주소를 통해서 해당 행의 위치를 빠르게 접근하는 것이 가능
          데이터가 입력이 될 때 생성  
 . INDEX는 정렬되어 있으므로 ROWID를 사용하여 테이블을 더욱 빠르게 조회 가능     
 . 여러 추가 가능
          
 SELECT ROWID, emp.*
 from emp
 WHERE ROWID = 'AAAE5gAAFAAAACPAAA';

 SELECT emp.*
 from emp
 WHERE empno = 7782;
 
 SELECT empno, ROWID
 from emp
 WHERE empno = 7782; 
 
 --정렬이 되어있을 때는 내가 찾고자 하는 행을 빨리 찾을 수 있다
 SELECT *
 from emp
 WHERE ROWID = 'AAAE5gAAFAAAACPAAA';

EXPLAIN PLAN FOR  --밑에 있는 쿼리의 실행계획을 만들어라라는 뜻
SELECT *          
FROM emp
WHERE empno = 7782;

SELECT *          --실행계획 반환
FROM TABLE (DBMS_XPLAN.DISPLAY);
--NAME 이후 반환내용은 예측이기 때문에 보지말기

오라클 객체 생성
CREATE 객체 타입(INDEX, TABLE...)객체명
JAVA  :  int    변수명

인덱스 생성   
CREATE [UNIQUE] INDEX 인덱스 이름 ON 테이블명 (컬럼1, 컬럼2...); 
--동일 데이터를 만들 수 없음 (중복 불가능)
ex.
CREATE UNIQUE INDEX PK_emp ON emp(empno);  

-- 2-1-0
EXPLAIN PLAN FOR 
SELECT *
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);

-- 1-0 / 테이블을 안읽었음 -> empno컬럼이 인덱스에 있어서 테이블에 접근을 하지 않음 
EXPLAIN PLAN FOR 
SELECT empno
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);

DROP INDEX PK_EMP;
CREATE INDEX IDX_emp_01 ON emp (empno);

---------
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno =7782;

select *
from table (DBMS_XPLAN.DISPLAY);
-- INDEX RANGE SCAN  => 중복이 가능하여 range /  UNIQUE차이점은 한건을 읽는지 여러건을 읽는지 차이

---------
job컬럼에 인덱스 생성
CREATE INDEX idx_emp_02 ON emp (job);
--order by로 정렬이 되어 있어서 UNIQUE를 사용을 안해도 중복 접근 후 끝남
SELECT job, ROWID
FROM emp
ORDER BY job;

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job ='MANAGER';

select *
from table (DBMS_XPLAN.DISPLAY);

--------
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job ='MANAGER'
    AND ename LIKE 'C%';  --인덱스와 관련 없는 조건이므로 테이블을 읽지 않으면 알 수 없음

select *
from table (DBMS_XPLAN.DISPLAY);
--4건의 인덱스와 3건의 테이블에 접근해서 조건에 만족하지 않은 것은 버림 => 총 1건이 나옴

---------
CREATE INDEX IDX_EMP_03 ON emp (job, ename);

select job, ename, ROWID
FROM emp
ORDERBY job, ename;

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job ='MANAGER'
    AND ename LIKE 'C%';  

select *
from table (DBMS_XPLAN.DISPLAY);
--job = manager인 인덱스에서 c로 시작하는 데이터 먼저 접근 후 2건의 인덱스 중 c로 시작하지 않는 것은 접근하지 않음

---------
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job ='MANAGER'
    AND ename LIKE '%C';  

select *
from table (DBMS_XPLAN.DISPLAY);
--정렬의 의미가 없음 -=> C로 끝나는 조건이기 때문에
--job = manager인 인덱스를 읽은 후 (4건) C로 끝나는 조건을 만족하는 데이터가 없으면 인덱스에서 끝냄 (테이블까지 가지 않음)