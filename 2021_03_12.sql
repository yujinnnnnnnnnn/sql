SELECT mem_id, mem_pass, mem_name
FROM member;

컬럼 정보를 보는 방법
1. SELECT * ==> 컬럼의 이름을 알 수 있음
2. SQL DEVELOPER의 테이블 객체를 클릭하여 정보확인
 데이터 타입 => 문자(), 숫자(number), 날짜(date)
 (4.0)=>(전체자릿수.소수점없음)
 문자열 => VARCHAR2 (10 BYTE)(10 바이트로 길이를 제한함)
3. DESC 테이블명; //DESCRIBE의 약자 -설명하다
 null=> 값을 모르는 것 

DESC emp;

empno : number;
empno + 10 ==> expression
SELECT empno empnumber, empno + 10 emp_plus , 10,
       hiredate, hiredate + 10
FROM emp;

널? => 널값을 허용할 수 있는 가? 잘못된값을 설정할 수 있음
유형 => 타입을 뜻함
날짜는  +, - 만 가능(= hiredate)

 숫자, 날짜에서 사용가능한 연산자
 일반적인 사칙연산 + - * / , 우선순위 연산자 ()
 
 ALIAS :컬럼의 이름을 변경
        컬럼 | expression [AS] [별칭명]
 SELECT empno "emp no", empno + 10  AS empno_plus
 FROM emp;
 
 NULL : 아직 모르는 값
        0과 공백은 NULL과 다르다.
        ****NULL을 포함한 연산은 결과가 항상 NULL****
        ==> NULL 값을 다른 값으로 치환해주는 함수(나중에 배움)
        
 SELECT ename, sal, comm, sal + comm, comm + 100
 FROM emp;
  
  
 --===============실습===================
 select[2]
 
 --prod 테이블에서  prod_id, prod_name 두 컬럼을 조회하는 쿼리 작성
 --(단, id, name으로 컬럼 별칭 지정)
   SELECT prod_id "id", prod_name "name"
   FROM prod;
   
 --lprod 테이블에서 lprod_gu, prod_nm 두 컬럼을 조회하는 쿼리 작성
 --(단, gu,nm 으로 컬럼 별칭 지정)
   SELECT lprod_gu AS "gu", lprod_nm AS "nm"
   FROM lprod;
 
 --buyer 테이블에서 buyer_id, buyer_name 두 컬럼을 조회하는 쿼리 작성
 --(단, 바이어아이디, 이름 으로 컬럼 별칭 지정) 
   SELECT buyer_id AS 바이어아이디, buyer_name AS 이름
   FROM buyer;
   
   literal : 값 자체를 의미
   literal 표기법 : 값을 표현하는 방법
   
 java 정수 (10) 어떻게 표현?  
  int a = 10;
  float f = 10f;
  long l = 10L;
  String s = "Hello world";
  
  java 문자열 어떻게 표현?
  =>""
  sql 문자열 어떻기 표현?
  =>''
  
  SELECT empno, 10, 'Hello world' 
  FROM emp;
  
  --문자열에 '' 안넣었을때 오류
  *|{컬럼 | 표현식 [AS] [ALIAS], ...}
  SELECT empno, 10, Hello world -> 컬럼과 표현식으로 인식 
  FROM emp;
  
  문자열 연산
  java : String msg +"Hello"+ ", World";
  
  SELECT empno + 10, ename || 'World' 
         CONCAT(ename, ', World') -- 결합할 두개의 문자열을 입력받아 결합하고 결합된 문자열을 반환 해준다 
  FROM emp;
  

  DESC emp;
  
  아이디 : brown
  이디이 : apeach
  .
  .
  SELECT '아이디 :' || userid,
         CONCAT('아이디 :', userid)
  FROM users;
  
  --문자열 결합 실습 sel_con1  
  SELECT 'SELECT * FROM ' || table_name || ';' AS QUERY,
          CONCAT(CONCAT('SELECT * FROM ', table_name),' ;') AS QUERY
  FROM user_tables;  
  
  
--조건에 맞는 데이터 조회하기
 WHERE절 조건연산자
 => = 같은값
    !=,<> 다른 값
    > 클때
    < 작을때
    >= 크거나 같음
    <= 작거나 같음
    
    --부서번호가 10인 직원들만 조회
    --부서번호 : deptno
    
    -- users 테이블에서 userid 컬럼의 값이 brown인 사용자만 조회
    --*********SQL 키워드는 대소문자를 가리지 않지만 데이터 값은 대소문자 가림
    SELECT *
    FROM users
    WHERE userid = 'brown'; -- 데이터는 대소문자를 가리기 때문에 대문자로 하면 에러뜸
    
    --emp 테이블에서 부서번호가 20번보다 큰부서에 속한 직원 조회
    
    SELECT *
    FROM emp
    WHERE deptno > 20;
    
    ----emp 테이블에서 부서번호가 20번 부서에 속하지 않은 모든 직원 조회
    SELECT *
    FROM emp
    WHERE deptno != 20; 
    
    WHERE :기술한 조건을 참(TRUE)으로 만족하는 행들만 조회한다.(FILTER)
    
    --
    SELECT *
    FROM emp
    WHERE 1=1; -- 1=1은 참이므로 모든 행 출력함
    
    81년 3월 1일 날짜 값을 표기하는 방법
    SELECT empno, ename, hiredate
    FROM emp
    WHERE hiredate >= '81/03/01'; --81년 3월 1일 날짜 값을 표기하는 방법
    날짜를 오라클에서 표시하는 것은 문자열로 표시함
    하지만 국적마다 년도,월,일 적는 순위가 다름
    
    문자열을 날짜 타입으로 변환하는 방법
    TO_DATE(날짜 문자열, 날짜 문자열의 포맷팅)
    TO_DATE('1981/03/01', 'YYYY/MM/DD') -- 년도 월 일 이 언제인지 알 수 없음
    

    SELECT empno, ename, hiredate
    FROM emp
    WHERE hiredate >= TO_DATE('1981/03/01', 'YYYY/MM/DD');
    
    
    
    도구 환경설정 데이터베이스 nls 날짜형식 YYY/MM/DD HH: