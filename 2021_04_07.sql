<<반복문>>
-개발언어의 반복문과 같은 기능 제공
- LOOP, WHILE, FOR 문
 1)LOOP 문
  .반복문의 기본 구조
  .JAVA의 DO문과 유사한 구조임
  .기본적으로 무한루프 구조
  (사용형식)
  LOOP
    반복처리문(들);
    [EXIT WHEN 조건;] --조건이 맞으면 빠져나감(멈춤) / while 문은 조건이 거짓일때 멈춤
  END LOOP;
   - 'EXIT WHEN 조건' : '조건'이 참인 경우 반복문의 범위를 벗어남
ex) 구구단의 7단을 출력
DECLARE
    V_CNT NUMBER :=1; --곱해지는 값
    V_RES NUMBER :=0; --NUMBER는 반드시 초기화 시켜야함
BEGIN
    LOOP
        V_RES := 7* V_CNT;
        DBMS_OUTPUT.PUT_LINE(7 || '*' || V_CNT || '=' || V_RES ); 
        V_CNT := V_CNT + 1;
        EXIT WHEN V_CNT > 9;  --9와 같거나 크다로 하면 9가 안찍히므로 >
    END LOOP;
END;

EX) 1-50사이의 피보나치수를 구하여 출력하시오
FIBONACCI NUMBER : 첫번쨰와 두번째 수가 1,1로 주어지고 세번째 수부터 전 두수의 합이 현재수가 되는 수열 -> 검색 알고리즘애 사용
DECLARE
    V_PNUM NUMBER :=1; --전수
    V_PPNUM NUMBER :=1; --전전수
    V_CURRNUM NUMBER := 0; --현재수
    V_RES VARCHAR(100);
BEGIN
    V_RES := V_PPNUM || ', ' || V_PNUM;
    
    LOOP
        V_CURRNUM := V_PPNUM + V_PNUM;
        EXIT WHEN V_CURRNUM >= 50;
        V_RES := V_RES || ', ' || V_CURRNUM;
        V_PPNUM := V_PNUM;  --★전 두수의 값 구하기 => 그 다음 수는 전 수는 전전수, 현재수가 전수가 되어야함
        V_PNUM := V_CURRNUM; --★
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('1~50사이의 피보나치 수 : ' ||V_RES);
END;

 2) WHILE 문
  . 개발언어의 WHILE문과 같은 기능
  . 조건을 미리 체크하여 조건이 참인 경우에만 반복처리
  (사용형식)
  WHILE 조건
    LOOP
        반복처리문(들);
    END LOOP;

EX) 첫날에 100원 둘째날 부터 전날의 2배씩 저축할 경우 최초로 100만원을 넘는 날과 저축한 금액을 구하시오
--(1) 변수가 몇개가 필요한지 생각
DECLARE 
    V_DAYS NUMBER := 1; --날짜
    V_AMT NUMBER := 100; --날짜별 저축할 금액
    V_SUM NUMBER := 0; --저축한 전체 합계
BEGIN
    --V_SUM 에 날째별 저축금액을 더하면 하루가 지났다는 뜻
    WHILE V_SUM < 1000000 LOOP
        V_SUM := V_SUM + V_AMT; --첫날 저금
        V_DAYS := V_DAYS + 1;
        V_AMT := V_AMT * 2;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('날수 : ' || (V_DAYS -1));
    DBMS_OUTPUT.PUT_LINE('저축액수  : ' || V_SUM);
END;

EX) 회원테이블(MEMBER) 에서 마일리지가 3000이상인 회원들을 찾아 그들이  2005년 5월 구매한 횟수와 구매금액합계를 구하시오(커서사용)
    출력은 회원번호(cart), 회원명, 구매횟수, 구매금액 , prod테이블 / count사용  /출력은 반드시 변수
    멤버테이블에서 3000이상인 회원들을 뽑는 것이 커서가하는일 -> 뽑은 것을 매출 테이블로 가서 
SELECT *
FROM MEMBER;
    
(1)LOOP 사용한 커서실행
DECLARE
    V_MID MEMBER.MEM_ID%TYPE;  --회원번호
    V_MNAME MEMBER.MEM_NAME%TYPE;  --회원명
    V_CNT NUMBER := 0;  --구매횟수
    V_AMT NUMBER := 0;  --구매금액 합계
    
    CURSOR CUR_CART_AMT
    IS
        SELECT MEM_ID, MEM_NAME 
            FROM MEMBER
        WHERE MEM_MILEAGE >= 3000;
BEGIN
    OPEN CUR_CART_AMT;--커서를 하나씩 읽어서 읽은회원번호를 가지고 카트테이블 살펴봄
    
    LOOP
        FETCH CUR_CART_AMT INTO V_MID, V_MNAME;
        EXIT WHEN CUR_CART_AMT%NOTFOUND;
        SELECT SUM(A.CART_QTY * B.PROD_PRICE), --합계,구매횟수
            COUNT (A.CART_PROD) INTO  V_AMT, V_CNT 
        FROM CART A, PROD B
        WHERE A.CART_PROD = B.PROD_ID -- 상품에 대한 단가 조인
            AND A.CART_MEMBER = V_MID
            AND SUBSTR(A.CART_NO,1,6) = '200505';
            
            DBMS_OUTPUT.PUT_LINE( V_MID || ', ' || V_MNAME || ' => ' || V_AMT || '(' || V_CNT || ')');
    END LOOP;
    CLOSE CUR_CART_AMT;
END;

(2)WHERE 문 사용
DECLARE
    V_MID MEMBER.MEM_ID%TYPE;  --회원번호
    V_MNAME MEMBER.MEM_NAME%TYPE;  --회원명
    V_CNT NUMBER := 0;  --구매횟수
    V_AMT NUMBER := 0;  --구매금액 합계
    
    CURSOR CUR_CART_AMT
    IS
        SELECT MEM_ID, MEM_NAME 
            FROM MEMBER
        WHERE MEM_MILEAGE >= 3000;
BEGIN
    OPEN CUR_CART_AMT;--커서를 하나씩 읽어서 읽은회원번호를 가지고 카트테이블 살펴봄
    FETCH CUR_CART_AMT INTO V_MID, V_MNAME;
    
    WHILE CUR_CART_AMT%FOUND LOOP     
        EXIT WHEN CUR_CART_AMT%NOTFOUND;
        SELECT SUM(A.CART_QTY * B.PROD_PRICE), --합계,구매횟수
            COUNT (A.CART_PROD) INTO  V_AMT, V_CNT 
        FROM CART A, PROD B
        WHERE A.CART_PROD = B.PROD_ID -- 상품에 대한 단가 조인
            AND A.CART_MEMBER = V_MID
            AND SUBSTR(A.CART_NO,1,6) = '200505';
            
            DBMS_OUTPUT.PUT_LINE( V_MID || ', ' || V_MNAME || ' => ' || V_AMT || '(' || V_CNT || ')');
       FETCH CUR_CART_AMT INTO V_MID, V_MNAME;
    END LOOP;
    CLOSE CUR_CART_AMT;
END; --조건이 안맞아서 안보임 => / WHILE 문은 반드시 FETCH가 밖에 있고 END LOOP전에 하나더 있어야됨

 3)FOR 문 --DECLARE 선언을 안해도됨 (자동 설정됨)
    .반복횟수를 알고 있거나 횟수가 중요한 경우 사용
    (사용혁식 -1 : 일반적 FOR)
    FOR 인덱스 IN [REVERSE] 최솟값..최대값
    LOOP            --역순으로 회전 / 증가 OR 감소 뿐
        반복처리문(들);
    END LOOP;
    
EX) 구구단의 7단을 FOR문을 이용하여 구성
DECLARE 
 --   V_CNT NUMBER := 1; --승수(1~9)
--    V_RES NUMBER := 0; --결과  ==> 안쓰는 대신 직접 출력란에 적음
BEGIN
    FOR I IN 1..9 LOOP
--    V_RES := 7*I;
    DBMS_OUTPUT.PUT_LINE(7 || '*' || I || '=' || 7*I);
  END LOOP;
END;

    (사용혁식 -2 : CURSOR에 사용하는 FOR)
    FOR 레코드명 IN 커서명 | (커서 선언문) 
    LOOP         
        반복처리문(들);
    EXIT LOOP;
    .'레코드명' 은 시스템에서 자도으로 설정
    .커서 컬럼 참조형식 : 레코드명.커서컬럼명 --커서의 한줄을 레코드명에 넣어줌
    .커서명 대신 커서 선언문(선언부에 존재했던)이 INLINE형식으로 기술할 수 있음 --선언부에 기술하지않고 직접 FOR문안에서 기술가능(서브쿼리같이)
    .FOR문을 사용하는 경우, 커서의 OPEN, FETCH, CLOSE 문은 생략함 --변수선언 안해도됨 (레코드명.커서컬럼명으로 접근하기 때문에) /변수선언이유는 패치문에 넣어주기 위해서임  
   
    (for문사용)
    DECLARE
    V_CNT NUMBER := 0;  --구매횟수
    V_AMT NUMBER := 0;  --구매금액 합계
    
    CURSOR CUR_CART_AMT
    IS
        SELECT MEM_ID, MEM_NAME 
            FROM MEMBER
        WHERE MEM_MILEAGE >= 3000;
BEGIN   
        FOR REC_CART IN CUR_CART_AMT LOOP     
        SELECT SUM(A.CART_QTY * B.PROD_PRICE), --합계,구매횟수
            COUNT (A.CART_PROD) INTO  V_AMT, V_CNT 
        FROM CART A, PROD B
        WHERE A.CART_PROD = B.PROD_ID -- 상품에 대한 단가 조인
            AND A.CART_MEMBER = REC_CART.MEM_ID  --CURSOR는 7명을 다가지고 있어서 커서의 한줄을 레코드명에 넣어주면서 CART_MEMBER에 넣어줌
            AND SUBSTR(A.CART_NO,1,6) = '200505';
            
            DBMS_OUTPUT.PUT_LINE( REC_CART.MEM_ID || ', ' || REC_CART.MEM_NAME || ' => ' || V_AMT || '(' || V_CNT || ')');

    END LOOP;
END;
   
    (for문에서 INLINE 커서 사용) --제일 많이 사용
 DECLARE
    V_CNT NUMBER := 0;  --구매횟수
    V_AMT NUMBER := 0;  --구매금액 합계
    
BEGIN   
        FOR REC_CART IN (SELECT MEM_ID, MEM_NAME --커서명 나올자리에 커서본문을 서브쿼리 형식으로 기술 
                           FROM MEMBER
                          WHERE MEM_MILEAGE >= 3000)
        LOOP     
        SELECT SUM(A.CART_QTY * B.PROD_PRICE), --합계,구매횟수
            COUNT (A.CART_PROD) INTO  V_AMT, V_CNT 
        FROM CART A, PROD B
        WHERE A.CART_PROD = B.PROD_ID -- 상품에 대한 단가 조인
            AND A.CART_MEMBER = REC_CART.MEM_ID  --CURSOR는 7명을 다가지고 있어서 커서의 한줄을 레코드명에 넣어주면서 CART_MEMBER에 넣어줌
            AND SUBSTR(A.CART_NO,1,6) = '200505';
            
            DBMS_OUTPUT.PUT_LINE( REC_CART.MEM_ID || ', ' || REC_CART.MEM_NAME || ' => ' || V_AMT || '(' || V_CNT || ')');

    END LOOP;
END;
        
<<<<<<<저장프로시져(Stored Procedure :Procedure)>>>>>>>>>>>  
- 특정 결과를 산출하기 위한 코드의 집합(모듈)
- 반환값이 없음 --반환하는 값은 :FUNCTION (SELECT ,WHERE)
- 컴파일되어 서버에 보관 (실행속도를 증가, 은닉성, 보안성) --필요시 호출에서 사용
- 독립적으로 쓰여야함 함수랑 쓰는 위치가 다름
 (사용형식)
 .CREATE [OR REPLACE] PROCEDURE 프로시져명(= PROC_~)[( 
 매개변수명 [IN | OUT| INOUT]데이터타입 [[:= | DEFAULT] expr],
 매개변수명 [IN | OUT| INOUT]데이터타입 [[:= | DEFAULT)] expr],
                      .
                      .
-- 밖으로 내보냄(OUT:출력용), 밖에서 안으로 자료가져옴(IN:입력용)
 매개변수명 [IN | OUT| INOUT]데이터타입 [[:= | DEFAULT] expr])]
 AS | IS                  --데이터 타입만 기술 / 크기는 지정하는거 아님
    선언영역; --DECLARE 영역
 BEGIN
    실행영역;
 END;
 
 **다음 조건에 맞는 재고수불 테이블을 생성하시오
 1. 테이블명 : REMAIN
 2. 컬럼
 --------------------------------------------------------
 컬럼명         데이터타입                  제약사항
 --------------------------------------------------------
 REMAIN_YEAR     CHAR(4)                    PK
 PROD_ID         VARCHAR2(10)               PK &FK
 REMAIN_J_00     NUMBER(5)                  DEFAULT 0 --기초재고
 REMAIN_I        NUMBER(5)                  DEFAULT 0 --입고수량
 REMAIN_O        NUMBER(5)                  DEFAULT 0 --출고수량
 REMAIN_J_99     NUMBER(5)                  DEFAULT 0 --기말재고
 REMAIN_DATE     DATE                       DEFAULT SYSDATE --처리일자
 
 CREATE TABLE REMAIN(
    REMAIN_YEAR     CHAR(4),         
    PROD_ID         VARCHAR2(10),    
    REMAIN_J_00     NUMBER(5)  DEFAULT 0,
    REMAIN_I        NUMBER(5)  DEFAULT 0, 
    REMAIN_O        NUMBER(5)  DEFAULT 0,
    REMAIN_J_99     NUMBER(5)  DEFAULT 0, 
    REMAIN_DATE     DATE  --);   
 
--  한번에 기본키 외래키 설정 방법
-- ALTER TABLE REMAIN
--    ADD CONSTRAINT pk_remain PRIMARY KEY (REMAIN_YEAR, PROD_ID); --기본키
--     CONSTRAINT fk_remain_prod FOREIGN KEY(PROD_ID) --외래키
--        REFERENCES PROD (PROD_ID)); 

-- 외래키 추가
 ALTER TABLE REMAIN
    ADD CONSTRAINT fk_remain_prod FOREIGN KEY(PROD_ID) --외래키
        REFERENCES PROD (PROD_ID);
        
**REMAIN 테이블에 기초자료 삽입
--년도,제품코드, 기준이 되어지는 일자에 파악한 / 각 상품별 재고수량을 집어넣는것 
--재고파일 과 상품코드파일은 반드시 일치
--PROD_ID 제품코드 / PROD_NAME 제품명 / PROD_TOTALSTOCK 전체 재고량 / PROD_PROPERSTOCK 적정재고량(토탈스톡값보다 높음) [적정재고량- 전체재고량 = 자동발주량]
 년도 : 2005
 상품코드 : 상품테이블의 상품코드
 기초재고 : 상품테이블의 적정재고(PROD_PROPERSTOCK)
 입고수량/출고수량 : 없음
 처리일자 : 2004년 12월 31일
 
 INSERT INTO REMAIN(REMAIN_YEAR, PROD_ID, REMAIN_J_00, REMAIN_J_99, REMAIN_DATE) --서브쿼리 사용시 VAIUSE,() 사용안함
    SELECT '2005', PROD_ID, PROD_PROPERSTOCK, PROD_PROPERSTOCK, TO_DATE('20041231')
    FROM PROD;
    
SELECT * FROM REMAIN;

(1.테이블 컬럼명 변경)
ALTER TABLE 테이블명
    RENAME COLUMN 변경대상컬럼명 TO 변경컬럼명;
EX) TEMP 테이블의 ABC를 QAZ라는 컬럼명으로 변경
ALTER TABLE TEMP
    RENAME COLUMN ABC TO QAZ;
(2.컬럼 데이터타입 (크기)변경)
ALTER TABLE 테이블명
    MODIFY 컬럼명 데이터타입(크기);
EX) TEMP 테이블의 ABC컬럼을 NUMBER(10)으로 변경
ALTER TABLE TEMP
    MODIFY ABC NUMBER(10);
  --해당 컬럼의 내용을 모두 지워야 변경 가능

    
 **테이블 생성명령
 CREATE TABLE 테이블명(
    컬럼명1 데이터타입[(크기)] [NOT NULL][DEFAULT 값 | 수식][,] --INSERT를 사용했을 때
    컬럼명2 데이터타입[(크기)] [NOT NULL][DEFAULT 값 | 수식][,]
                            .
                            .
    컬럼명n 데이터타입[(크기)] [NOT NULL][DEFAULT 값 | 수식][,] --여기서 끝내면 기본키와 외래키를 설정안한게됨
    
    CONSTRAINT 기본키설정명 PRIMARY KEY (컬럼명1[, 컬럼명2, ...])[,] --PK_테이블명으로 시작함 (중복제거)
    CONSTRAINT 외래키설정명 FOREIGN KEY (컬럼명1[, 컬럼명2, ...]) --복수컬럼명 설정 경우 => 다른 테이블에 두개를가지고 와서 
        REFERENCES 테이블명1(컬럼명1[, 컬럼명2, ...])[,]  -- PK_테이블명_참조명
                            .
                            .
    CONSTRAINT 외래키설정명 FOREIGN KEY (컬럼명1[, 컬럼명2, ...]) --다른 각테이블에서 가져왔을 경우 사용 (외래키설정명 다르게 기술)
        REFERENCES 테이블명1(컬럼명1[, 컬럼명2, ...]) );
  