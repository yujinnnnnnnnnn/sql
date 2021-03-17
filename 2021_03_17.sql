<<<<<Function>>>>>

single row function
-단일 행을 기준으로 작업하고, 행당 하나의 결과를 반환
-특정 걸럼의 문자열 길이 : length(ename)
                               입력값(문자열)
                               
Multi row function
-여러 행을기준으 작업하고, 하나의 결과를 반환
-그룹함수 : count, sum, avg
-행의 건수를 반환해줌 
ex. 우리회사의 총 직원은 몇명인가

character
-대소문자
 LOWER  소문자로 만들어 주는 것 => 입력값이 문자, 들어가는 갯수가 1개 , 반환값은 문자
 UPPER  대문자로 만들어 주는 것 
 INITCAP  첫글자를 대문자로 만들어줌 
 -문자열 조작
 CONCAT 결합(연겨하다) => 인자 = 문자열 /결합된 값 하나
 SUBSTR 부분문자열 문자열의 일부분을 빼냄 
 LENGTH 
 INSTR 문자열에 내가 검색하고자하는 문자열이 있는지
  LPAD/ RPAE
  TRIM 공백제거 문자열 시작 앞부분, 뒷부분 (문자열 중간 공백은 제거 못함)
  REPLACE 교체함(치환) 대상문자열 바꾸고싶은 문자열 ,반환문자열 = 인자 3개

===생각해보는 연습하기==
함수명을 보고
1. 파라미터(=인자)가 어떤게 들어갈까?
2. 몇개의 파라미터(=인자)가 들어갈까
3.반환되는 값은 무엇일까?

select *|{컬럼| expression}

SELECT ename, LOWER(ename), UPPER(ename), INITCAP(ename)
FROM emp;

SELECT ename, LOWER(ename), LOWER('Test')
FROM emp;                       -- 문자열 리터널 (상수)

--substr사용법
SELECT ename, LOWER(ename), LOWER('Test'),
        SUBSTR(ename,2, 3),
        SUBSTR(ename, 2),
        REPLACE (ename, 'S','T')
FROM emp; 

DUAL table
-sys 계정에 있는 테이블 
-누구나 사용 가능
-DUMMY 커럼 하나만 존재하면 값은 'x'이며 테이터는 한 행만 존재
-데이터 관련 없을 때 사용/ 테스트목적으로 사용 많이함

SELECT *
FROM dual;


SELECT LENGH('TEST')
FROM dual;

사용용도
-데이터와 관련 없이
 함수실행
  시퀀스 실행
-merge문에서 (INSERT + UPDATE)
데이터복제시 (connect by level)

SELECT *
FROM dual
connect by level <=10;

single row function: WHERE 절에서도 사용 가능
emp테이블 등록된 직원들 중에 직원의 이름의 길이가 5글자를 초과하는 직원만 조회

SELECT *
FROM emp
WHERE LENGTH (ename) > 5;

SELECT *
FROM emp
WHERE LOWER(ename) = 'smith';
= emp 모든 행을 실행해야함
--위아래 동일 값 나옴 위에 추천 X
SELECT *
FROM emp
WHERE ename = UPPER('smith');
--테이블 컬럼을 가공하지 말아야함
한번만 실행 가능

<문자열 함수>

SELECT 'HELLO' || ',' || 'WORLD',
        CONCAT('HELLO', CONCAT(',', 'WORLD'))CONCAT , --인자 2개로 지정되어있음
        SUBSTR('HELLO, WORLD', 1, 5) SUBSTR,
        LENGTH('HELLO, WORLD') LENGTH, --갯수
        INSTR('HELLO, WORLD', 'O') INSTR, --해당 문자열의 등장 번호수
        INSTR('HELLO, WORLD', 'O' , 6) INSTR2, --계층쿼리에서 쓰임
        --('XX회사- 개발본부-개발부-개발팀-개발파트') --자를 때 사용됨
        LPAD('HELLO, WORLD', 15 , '-') LPAD, -- 왼쪽으로 ''에 지정한 문자열 추가
        RPAD('HELLO, WORLD', 15 , '-') RPAD,
        REPLACE ('HELLO, WORLD', 'O' , 'X') REPLACE,
        TRIM('    HELLO, WORLD    ') TRIM, -- 공백 제거 문자열 앞 뒤만
        TRIM('D' FROM 'HELLO, WORLD') TRIM -- 'D'라는 문자열을 없앰 
FROM dual;

---------------------숫자 함수--------------------------
NUMBER (숫자조작)
- ROUND (반올림) -> 인자 2개
- TRUNC (내림, 버림) -> 인자 2개
- MOD (나눗셈의 나머지) -> 인자 2개

JAVA : 10%3 -> 1;

피제수, 제수
SELECT MOD (10, 3)
FROM dual;

SELECT
ROUND(105.54, 1) ROUND1, --반올림 결과가 소수점 첫번째 자리까지 나오도록 : 소수점 둘째 자리에서 반올림 = 105.5
ROUND(105.55, 1) ROUND2,--반올림 결과가 소수점 첫번째 자리까지 나오도록 : 소수점 둘째 자리에서 반올림 = 105.6
ROUND(105.55, 0) ROUND3, --반올림 결과가 첫번째 (일의자리)자리까지 나오도록 : 소수점 첫째 자리에서 반올림 = 106
ROUND(105.55, -1) ROUND4, --반올림 결과가 두번째(십의자리) 자리까지 나오도록 : 정수 첫째 자리에서 반올림 = 110
ROUND(105.55) ROUND5 ---두번째 자리가 없으면 정수 첫째자리까지 나오도록 : 소수점 모두 제거 = 106
FROM dual;

-----이렇게 쓰면 안됨
SELECT *
FROM emp
WHERE ename = SMITH;
--------------------

SELECT
TRUNC(105.54, 1)TRUNC1 , --절삭 결과가 소수점 첫번째 자리까지 나오도록 : 소수점 둘째 자리에서 절삭 = 105.5
TRUNC(105.55, 1) TRUNC2,--절삭 결과가 소수점 첫번째 자리까지 나오도록 : 소수점 둘째 자리에서 절삭 = 105.5
TRUNC(105.55, 0) TRUNC3, --절삭 결과가 첫번째 (일의자리)자리까지 나오도록 : 소수점 첫째 자리에서 절삭 = 105
TRUNC(105.55, -1) TRUNC4, --절삭 결과가 두번째(십의자리) 자리까지 나오도록 : 정수 첫째 자리에서 절삭 = 100
TRUNC(105.55) TRUNC5 --두번째 자리가 없으면 정수 첫째자리까지 나오도록 : 소수점 모두 제거= 105
FROM dual;

-- ex : 7499, allen, 1600, 1 ,600
SELECT empni, ename, sal, sal을 1000으로 나눴을 때의 몫, sal을 1000우로 나웠을 때의 나며지
FROM emp;

SELECT empno, ename, sal, TRUNC(sal/1000.0) --몫은 반올림하면 안되므로 TRUNC 사용  
FROM emp;

SELECT empno, ename, sal, MOD (sal, 1000) 
FROM emp;

날짜 <=> 문자
서버의 현재 시간 : SYSDATE 서버의 현재 시간/ 날짜 반환
-- 오라클 = 인자가 없으면 () 안써도됨 자바 = 메서드의 인자가 없더라도 ()써줘야함

SELECT SYSDATE + 1/24/60/60 --하루/한시간/분/초 을 더하라는 뜻 (빼기도 가능)       
FROM dual;

1. 2019 12 31일을 date형으로 표현
2. 2019 12 31일을 date형으로 표현하고 5일 이전 날짜
3.현재 날짜
4.현재날짜에서 3일 전 값

SELECT TO_DATE ('2019-12-31', 'YYYY-MM-DD') , 
    TO_DATE ('2019-12-31', 'YYYY-MM-DD') -5, 
    SYSDATE , 
    SYSDATE -3            
FROM dual;

TO_DATE : 인자-문자, 문자의 형식 -- 문자를 날짜로 바꿔줌
TO_CHAR : 인자-날짜, 문자의 형식 -- 날짜를 문자로 바꿔줌

--<날짜를 문자로 바꾸는 것>
SELECT SYSDATE, TO_CHAR(SYSDATE , 'YYYY/MM/DD')
FROM dual;

<date>
- 형변환(DATE -> CHARACTER)
  T0_CHAR()

-FORMAT
 YYYY : 4자리 년도
 MM : 2자리 월
 DD : 2자리 일자
 D : 주간 일자 (1~7)
 IW : 주차 (1~54)
 HH, HH12 : 2자리 시간 (12시간 표현)
 HH24 : 2자리 시간 (24시간 표현)
 MI : 2자리 분
 SS : 2자리 초
 
-- D = 0-일요일, 1-월요올, 2-화요일,...6- 토요일
SELECT SYSDATE, TO_CHAR(SYSDATE , 'IW'), TO_CHAR(SYSDATE , 'D')--오늘이 이번년도의 몇주차인지 알 수 있음
FROM dual;

오늘 날짜를 다음과 같은 포맷으로 조회
년- 월- 일
년-월- 일 시간 (24)- 분- 초
일 월 년

SELECT TO_CHAR(SYSDATE , 'YYYY-MM-DD') DT_DASH, 
     TO_CHAR(SYSDATE , 'YYYY-MM-DD HH24:MI:SS') DT_DASH_WITH_TIME
    ,TO_CHAR(SYSDATE , 'DD-MM-YYYY') DT_DD_MM_YYYY
FROM dual;

TO_DATE(문자열, 문자열 포멧)

SELECT (TO_CHAR(SYSDATE , 'YYYY/MM/DD'))
FROM dual;

'2021-03-17' --> '2021-03-17 00:00:00'
SELECT TO_CHAR(TO_DATE('2021-03-14','YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS')
FROM dual; 

 


