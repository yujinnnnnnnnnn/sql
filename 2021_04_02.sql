SEQUENCE 객체
- 자동으로 증가되는 값을 반환할 수 있는 객체
- 테이블에 독립적(다수의 테이블에서 동시 참조 가능)
- 기본키로 설정할 적당한 컬럼이 존재하지 않는 경우 컬럼의 속성으로 주로 사용됨
  (사용형식)
  CREATE SEQUENCE 시퀀스명 
    [START WITH n]
    [INCREMENT BY n]
    [MAXVALUE n | NOMAXVALUE]
    [MINVALUE n| NOMINVALUE]
    [CYCLE | NOCYCLE]
    [CACHE n |NOCACHE]
    [ORDER| NOORDER]
    
    .START WITH n : 시작 값, 생략하면 MINVALUE
    .INCREMENT BY N : 증감값 생략시 1로 간주
    .MAXVALUE n : 사용하는 최대값, default 는 NOMAXVALUE 이고 10^27까지 사용
    .MINVALUE n : 사용하는 최소값, default 는 NOMINVALUE 이고 1
    .CYCLE : 최대(최소)까지 도달한 후 다시 시작할 것인지 여부, default 는 NOCYCLE 
    .CACHE n : 생성할 값을 캐시에 미리 만들어 사용 default 는 CACHE 20임 / 임시 메모리(시간 절약을 위함)
    .ORDER : 정의된대로 시퀀스 생성 강제(명령), default 는 NOORDER 
    (한번 건너뛴 숫자는 절대로 재사용이 안됨 시퀀스 객체의 증가 값과 실제 코드가 맞지 않아 오류가 발생하기 때문에 조심해서 사용)
    
    **시퀀스객체 의사(Pseudo Column)컬럼(가짜컬럼)
    1. 시퀀스명.NEXTVAL : '시퀀스'의 다음 값 반환
    2. 시퀀스명.CURRVAL : '시퀀스'의 현재 값 반환 
    --시퀀스가 생성되고 해당 세션의 첫번째 명령은 반드시 시퀀스.NEXTVAL 이어야 함
    
    
     ex. LPROD 테이블에 다음 자료를 삽입하시오(단, 시퀀스를 이용하시오)
  
    select *
    from lprod;
   
    [자료]
    LPROD_ID : 10번부터
    LPROD_GU : P501 ,      P502,     P503
    LPROD_NM : 농산물,     수산물,     임산물
    
    --(1) 시퀀스 생성
    CREATE SEQUENCE SEQ_LPROD
        START WITH 10;
        
    SELECT SEQ_LPROD.CURRVAL FROM DUAL; --테이블이 없어서 DUAL테이블 사용 / 에러 뜸 : CURRVAL를 먼저 사용했기 때문 (세션이 만들어 지긴 하지만 시퀀스에 배정되어진 값을 참조할 수 없음)
    
    --(2)자료 삽입
    INSERT INTO LPROD /*(컬럼명을 쓰는 경우 1. 자료삽입 시 어느컬럼에 대응되는것을 알지못해 알려주는 용도/ 2. 현재 테이블에 들어있는 모든 컬럼이 아닌 특정 컬럼만 사용할때 사용)*/
        VALUES(SEQ_LPROD.NEXTVAL/*(아이디에 추가)*/, 'p501','농산물');
    INSERT INTO LPROD VALUES(SEQ_LPROD.NEXTVAL, 'p502','수산물');
    INSERT INTO LPROD VALUES(SEQ_LPROD.NEXTVAL, 'p503','임산물');     
    select * from lprod;
    
    ===========================================
    ex. 오늘이 2005년 7월 28일인 경우 'null'회원이 제품 'P201000004'을 5개 구입했을때 CART테이블에 해당 자료를삽입하는 쿼리를 작성하시오
    --먼저 날짜를 2005년 07월 28일로 변경 후 작성할것  -> SYSDATE 사용하기 위해 현재 날짜를 변경해줌
    (매출이 발생되었을 때 발생된 매출을 매출테이블에 저장 ->INSERT , UPDATE, DELETE 가 발생된 것에 따라 이전, 이후의 반드시 실행되어야하는 쿼리를 자동으로 하는 객체 : Triger)
    
    --(1)날짜 변경
    select TO_CHAR(TO_CHAR( sysdate, 'yyyymmdd')|| MAX(SUBSTR(CART_NO,9)) +1)
    from cart;
    --간단한 방벙
    SELECT TO_CHAR(MAX(CART_NO)+1) FROM CART; --쓸 수 있는 이유 : 오라클은 문자열보다 숫자가 우선 / MAX를 사용했다는 것은 해당되어진 자료가 숫자로바껴서 제일 큰 값을 가져올 수있다는뜻
    

    --1.순번확인
    SELECT MAX(SUBSTR(CART_NO,9)) FROM CART; 
    
    --2.시퀀스 생성
        CREATE SEQUENCE SQL_CART
        START WITH 5;
        
        delete CART
        WHERE CART_NO = 
        
        INSERT INTO CART(CART_MEMBER, CART_NO, CART_PROD, CART_QTY)
            VALUES('m001',(TO_CHAR(SYSDATE, 'yyyymmdd') || TRIM (TO_CHAR(SQL_CART.NEXTVAL,'00000'))),'P201000004',5); --둘사이에 공백이 생기므로 TRIM 사용
            --                                                  5를 000005로 만들기 위해 to_char 사용
            --(게시판 사용시 유용)
    ========================================
            
    **시퀀스가 사용되는곳
    . SELECT 문의 SELECT 절(서브쿼리는 제외)
    . INSERT 문의 SELECT 절 (서브쿼리) [괄호안씀], VALUES 절
    . UPDATE 문의 SET절
    
    **시퀀스의 사용이 제한되는 곳
    . SELECT, DELETE , UPDATE 문에서 사용되는 Subquery
    . VIEW를 대상으로 사용하는 쿼리
    . DISTINCT가 사용된 SELECT 절
    . GROUP BY / ORDER BY 가 사용된 SELECT문
    .*집합 연산자 (UNION,MINUS,INTERSECT)가 사용된 SELECT 문
    .SELECT 문의 WHERE 절
    
    SYNONYM 객체
    - 동의어 의미
    - 오라클에서 생성된 객체에 별도의 이름 부여
    - 긴 이름의 객체를 쉽게 사용하기 위한 용도로 주로 사용
     (사용형식)
     CREATE [OR REPLACE] SYNONYM 동의어 이름 
        FOR 객체명;
        
    .'객체'에 별도의 이름인 '동의어 이름'을 부여
    (EX)
    HR계정의 REGIONS 테이블의 내용을 조회
    
    SELECT HR.REGIONS.REGION_ID AS 지역코드,
           HR.REGIONS.REGION_NAME AS 지역명
         FROM HR.REGIONS;  
    (테이블 별칭을사용한 경우)
    SELECT A.REGION_ID AS 지역코드,
           A.REGION_NAME AS 지역명
         FROM HR.REGIONS A;
    (동의어를 사용한 경우)
    CREATE OR REPLACE SYNONYM REG FOR HR.REGIONS;  --언제 어디에서나 REG를 사용가능
    
    SELECT A.REGION_ID AS 지역코드,
           A.REGION_NAME AS 지역명
         FROM REG A;
--동의어는 해당 데이터베이스를 사용하는 동안 계속 존재 

INDEX 객체
- 데이터 검색 효율을 증대 시키기위한 도구
- DBMS의 부하를 줄여 전체 성능향상
-별도의추가공간이 필요하고 INDEX FILE 을 위한 PROCESS 가 요구됨

1)인덱스가 요구되는 곳
 . 자주 검색되는 컬럼
 . 기본키(자동 인덱스 생성)와 외래키
 . SORT, GROUP 의 기본 컬럼
 . JOIN조건에 사용되는 컬럼

2) 인덱스가 불필요한 곳
 . 컬럼의 도메인이 적은 경우(성별, 나이 등)  
 . 검색조건으로 사용했으나 데이터의 대부분이 반환되는 경우
 . SELECT 보다 DML명령의 효율성이 중요한 경우

 3)인덱스의 종류
 (1)Unique 
   - 중복 값을 허용하지 않는 인덱스
   - NULL 값을 가질 수 있으나 이것도 중복해서는 안됨
   - 기본키, 외래키 인덱스가 이에 해당  
   (기본키 = 다른데이터와 구별할 수 있는 키 [속성 : 중복 배제 /NULL 값 있으면 안됨] )
 (2)Non Unique
   - 중복 값을 허용하는 인덱스 (null 중복 가능)
 (3)Noraml Index
   - default INDEX   
   - 트리 구조로 구성(동일 검색 횟수 보장)
   - 컬럼값과 ROWID(물리적 주소)를 기반으로 저장
 (4)Function-Based Normal Index
   - 조건절에 사용되는 함수를 이용한 인덱스
 (5)Bitmap Index 
   - ROWID와 컬럼 값을 이진으로 변환하여 이를 조합한 값을 기반으로 저장
   - 추가, 삭제, 수정이 빈버히 발생되는 경우 비효율적
 