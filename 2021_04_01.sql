view 는 table과 유사한 객체이다
view는 기존의 테이블이나 다른 view 객체를 통하여새로운 SELECT문의 결과를 테이블처럼 사용한다 (가상테이블)
 -view는 SELECT문에 귀속되는 것이 아니고, 독립적으로 테이블처럼 존재
 
view를 이용하는 경우
. 필요한 정보가 한 개의 테이블에 있지 않고, 여러개의 테이블에 분산되어 있는 경우
. 테이블에 들어 있는 자료의 일부분만 필요하고 자료의 전체 row나 colume 이 필요하지 않은 경우 [복잡한 서브쿼리와 조인을 사용하지 않아도됨]
. 특정 자료에 대한 접근을 제한하고자 할 경우(보안) 

오라클 객체
객체 생성 create 삭제 drop

인덱스객체 [찾기의 효율성을 증가 시키려고]

VIEW 객체
-TABLE과 유사한 기능 제공
- 보안, QUERY 실행의 효율성, TABLE의 은닉성을 위하여 사용
(사용형식)
CREATE [OR REPLACE][FORCE| NOFORCE] VIEW 뷰이름[(컬럼 LIST)]
AS   
    SELECT 문;
    [WITH CHECK OPTION;]
    [WITH READ ONLY;]
-- CREATE [OR REPLACE] = 하드 디스크에 이미 생성되어 있으면 대체하고, 없으면 생성
-- [FORCE| NOFORCE] = [원본테이블이 존재하지 않아도 뷰 생성 | 원본 테이블이 없으면 뷰 생성 불가능]
-- [컬럼LIST] = 생성된 뷰의 컬럼명 / SELECT 절 만큼
-- WITH CHECK OPTION = SELECT 문의 조건절(WHERE)에 위배되는 DML명령 실행 거부 (INSERT, UPDATE,DELETE 사용할 때 조건 체크)
-- WITH READ ONLY = 읽기전용 뷰 생성 / 원본 수정 불가 WITH CHECK OPTION 과 같이 사용불가

EX) 사원테이블에서 부모 부서코드가 90번부서에 속한서원정보를 조회하시오
    조회한 데이터 : 사원번호, 사원명, 부서명, 급여
    ======나중에 다시=====
    
EX2) 회원테이블에서 마일리지가 3000이상인 회원의 회원번호, 회원명, 직업, 마일리지를 조회하시오

SELECT mem_id AS 회원번호, mem_name AS 회원번호, mem_job AS 직업, mem_mileage AS 마일리지 
FROM member
WHERE mem_mileage >= 3000;

=> 뷰 생성
CREATE OR REPLACE VIEW V_MEMBER01
    AS
    SELECT mem_id AS 회원번호, mem_name AS 회원명, mem_job AS 직업, mem_mileage AS 마일리지 
    FROM MEMBER
    WHERE mem_mileage >= 3000;

SELECT * FROM V_MEMBER01;

신용환회원의 자료 검색
SELECT mem_name, mem_job, mem_mileage
FROM member
WHERE UPPER (MEM_ID) = 'C001'; -- UPPER를 사용하면 데이터의 대소문자 신경 안써도됨

MEMBER테이블에서 신용환의 마일리지를 10000으로 변경
UPDATE member 
SET mem_mileage = 10000  --이렇게만 실행하면 모든 마일리지가 10000으로 변경됨
WHERE mem_name= '신용환';
--원본테이블과 뷰는 연동되어져서 변경됨

V_MEMBER01에서 신용환의 마일리지를 500으로 변경
UPDATE V_MEMBER01
SET 마일리지 = 500
WHERE 회원명 = '신용환'; -- 뷰에서 없어짐 (3000이상인 마일리지의 뷰생성 조건에 부합하지 않아서 없어짐) / MEMBER테이블에는 변경됨 
                       
WITH CHECK OPTION 사용 뷰 생성 (테이블은 중복이 되어서 생성 불가능 하지만 뷰는 생성 가능)

CREATE OR REPLACE VIEW V_MEMBER01(MID,MNAME,MJOB,MILE)
    AS
    SELECT mem_id AS 회원번호, mem_name AS 회원명, mem_job AS 직업, mem_mileage AS 마일리지 
    FROM MEMBER
    WHERE mem_mileage >= 3000
    WITH CHECK OPTION;

SELECT * FROM V_MEMBER01;

뷰의 컬럼명 부여방식 3가지
 1. VIEW V_MEMBER01(MID,MNAME,MJOB,MILE) /뷰의 컬럼리스트
 2. SELECT문의 별칭
 3. SELECT 문의 별칭이 없을경우 컬럼명  

(뷰 V_MEMBER01에서 신용환 회원의 마일리지를 2000으로 변경) --조건보다 밑으로 변경시 변경 불가능 
UPDATE V_MEMBER01
SET MILE = 2000
WHERE UPPER(MID) = 'C001';

(테이블 MEMBER에서 신용환 회원의 마일리지를 2000으로 변경) --뷰와 관계없이 원본이 제한되면 안됨 (테이블에선 변경 가능) 
UPDATE member                                        -- 테이블 변경 후 뷰 조회 시 해당컬럼은 조건에 위배되어 뷰에서 삭제됨
SET mem_mileage = 2000
WHERE UPPER(MEM_ID) = 'C001';

--WITH READ ONLY 사용하여 VIEW 생성
CREATE OR REPLACE VIEW V_MEMBER01(MID,MNAME,MJOB,MILE)
    AS
    SELECT mem_id AS 회원번호, mem_name AS 회원명, mem_job AS 직업, mem_mileage AS 마일리지 
    FROM MEMBER
    WHERE mem_mileage >= 3000
    WITH READ ONLY; -- OR WITH CHECK OPTION 둘중하나만 사용가능

ROLLBACK; --원본데이터복구 밖으로 나가면 자동으로 커밋됨

--롤백을 해도 신용환의 마일리지는 바뀌지 않음
SELECT mem_name, mem_job, mem_mileage
FROM member
WHERE UPPER (MEM_ID) = 'C001';

SELECT * FROM V_MEMBER01;

(뷰 V_MEMBER01 에서 오철희 회원의 마일리지를 5700으로 변경)
UPDATE V_MEMBER01 
SET MILE = 5700
WHERE UPPER(MID) = 'K001';  --READ ONLY는 조작어 불가능 / SELECT 문만 가능 

-- 다른 계정에 있는 테이블 조회경우
SELECT HR.DEPARTMENTS.DEPARTMENT_ID,  --계정명.테이블명.컬럼명
        DEPARTMENT_NAME
FROM HR.DEPARTMENTS;    

--자바의 특성 = 재사용(reuse)


2021_0401_02)

문제 ] 사원테이블(EMPLOYEES)에서 50번 부서에 속한 서원 중 급여가 5000이상인 사원번호, 사원명, 입사일, 급여를 읽기 전용 뷰로 생성하시오
뷰이름은  v_emp_sal01이고 컬럼명은 원본테이블의 컬럼명을 사용
뷰가 생성된 후 해당 사원의 사원번호, 사원명, 직무명, 급여를 출력하는 SQL작성

CREATE OR REPLACE VIEW v_emp_sal01
AS
    SELECT EMPLOYEE_ID, EMP_NAME,
    HIRE_DATE, SALARY
    FROM employees
    WHERE DEPARTMENT_ID = 50 AND SALARY >= 5000
    WITH READ ONLY;
    
SELECT * FROM v_emp_sal01;
 
사원번호, 사원명, 직무명, 급여를 출력
SELECT C.EMPLOYEE_ID AS 사원번호, C.EMP_NAME AS 사원명, B.JOB_TITLE 직무명, C.SALARY AS 급여
FROM EMPLOYEES A, JOBS B, v_emp_sal01 C 
WHERE A.EMPLOYEE_ID = C.EMPLOYEE_ID
AND A.JOB_ID = B.JOB_ID;

CURSUR (SQL 명령에 의해 영향받은 행들의 집합)
명시적 CURSUR : 하나씩 꺼내서 읽을 수 있음
이름이 없는 CURSUR는 묵시적 CURSUR : 하나하나 꺼내올 수 없음 (외부접근 불가능)
 
SELECT HR.EMPLOYEES.*  --계정명.테이블명.컬럼명
FROM HR.EMPLOYEES;    

/*테이블별칭은 해당 쿼리에서만 사용
create synonym DEPARTMENTS FOR HR.DEPARTMENTS;
create synonym EMPLOYEES FOR HR.E; */