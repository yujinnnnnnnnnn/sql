ex) 오늘이 2005년1월 31일이라고 가정하고 오늘까지 발생된 상품입고 정보를 이용하여 재고 수불테이블을 update하는 프로시져를 생성하시오
 1)프로시져명 : PROC_REMAIN_IN
 2) 매개변수 : 상품코드, 매입수량
 3) 처리 내용 : 해당상품코드에 대한 입고수량, 현재고수량, 날짜 UPDATE
 
 (1)프로시져 밖에서 해줄내용 : 상품별 매입수량 집계 -> 상품수량코드를 프로시져로 넘겨줘야함
    --2005년 상품별 매입수량 집계 
 (2) 1의 결과 각 행을 PROCEDURE 에 전달 (한행씩)
 (3) PROCEDURE 에서 재고 수불테이블 UPDATE (재고처리해주기) 
 1)SELECT 
 2)GROUPING
 3) CURSOR
 
 --IN은 생략가능
 CREATE OR REPLACE PROCEDURE PROC_REMAIN_IN(
    P_CODE IN PROD.PROD_ID%TYPE,
    P_CNT IN NUMBER )--크기 X ,매개변수는 데이터타입만
IS
BEGIN
    UPDATE REMAIN    --↓변경을 하기위한 필요한 컬럼
        SET (REMAIN_I, REMAIN_J_99, REMAIN_DATE)=(SELECT REMAIN_I + P_CNT, 
                                                         REMAIN_J_99 + P_CNT,
                                                         TO_DATE('20050131')
                                                         FROM REMAIN
                                                         WHERE REMAIN_YEAR = '2005'
                                                            AND PROD_ID = P_CODE)
        WHERE REMAIN_YEAR = '2005'
            AND PROD_ID = P_CODE;       
END;
--CURSOR는 호출할때 필요

2. 프로시져 실행명령
 EXEC | EXECUTE 프로시져명[(매개변수 list)];

- 단, 익명블록 등 또다른 프로시져나 함수에서 프로시져 호출시 'EXEC | EXECUTE' 는 생략해야함
(2005년1월 상품별 매입집계) --상품별 (GROUP BY BUY_PROD)
SELECT BUY_PROD AS BCODE,
        SUM(BUY_QTY) AS BAMT
FROM BUYPROD
WHERE BUY_DATE BETWEEN '20050101' AND '20050131'
GROUP BY BUY_PROD;

(익명블록 작성)--프로시져 호출
DECLARE
    CURSOR CUR_BUY_AMT
    IS
        SELECT BUY_PROD AS BCODE,
            SUM(BUY_QTY) AS BAMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050101' AND '20050131'
        GROUP BY BUY_PROD;
BEGIN
    FOR REC01 IN CUR_BUY_AMT LOOP
    PROC_REMAIN_IN(REC01.BCODE , REC01.BAMT );--반복될 명령 : 우리가 만든 프로시져 호출 / REC01가 BCODE를 가리키고 있음
    END LOOP;
END;

**REMAIN 테이블의 내용을 VIEW로 구성(검증을 하기위한 것)**
CREATE OR REPLACE VIEW V_REMAIN01
AS
    SELECT * FROM REMAIN;

SELECT * FROM V_REMAIN01;

CREATE OR REPLACE VIEW V_REMAIN02
AS
    SELECT * FROM REMAIN
    
SELECT * FROM V_REMAIN01;
SELECT * FROM V_REMAIN02;

EX) 회원아이디를 입력 받아 그 회원의 이름, 주소와 직업을 반환하는 프로시져를 작성하시오
1. 프로시져명 : PROC_MEM_INFO  
2. 매개변수 : 입력용 : 회원아이디
             출력용 : 이름 ,주소, 직업 
(프로시져 생성)
CREATE OR REPLACE PROCEDURE PROC_MEM_INFO( --()매개변수 들어갈 자리
    P_ID IN MEMBER.MEM_ID%TYPE,        
    P_NAME OUT MEMBER.MEM_NAME%TYPE,
    P_ADDR OUT VARCHAR2,  
    P_JOB OUT MEMBER.MEM_JOB%TYPE)
AS
BEGIN
    SELECT MEM_NAME, MEM_ADD1 || ' ' || MEM_ADD2, MEM_JOB 
    INTO P_NAME, P_ADDR, P_JOB -- OUT으로 밖으로 나온 것들 - INTO 전에 있는 것들이 INTO 후에 있는 변수로 각 위치에 저장 
    FROM MEMBER
    WHERE MEM_ID = P_ID;
END;
(위에 컴파일 된것 실행)
ACCEPT PID PROMPT '회원아이디 : '
DECLARE 
    V_NAME MEMBER.MEM_NAME%TYPE;
    V_ADDR VARCHAR2(200);
    V_JOB MEMBER.MEM_JOB%TYPE;
BEGIN 
    PROC_MEM_INFO(LOWER('&PID'), V_NAME, V_ADDR, V_JOB);  --프로시져 호출
    DBMS_OUTPUT.PUT_LINE('회원아이디 : ' || '&PID');
    DBMS_OUTPUT.PUT_LINE('회원이름 : ' || V_NAME);
    DBMS_OUTPUT.PUT_LINE('회원주소 : ' || V_ADDR);
    DBMS_OUTPUT.PUT_LINE('회원주소 : ' || V_JOB);
END;

문제 ]년도를 입력 받아 해당년도에 구매를 가장 많이한 회원이름과 구매액을 반환하는 프로시져를 작성하시오  --MAX안에 SUM을 쓸수 없으므로 ROWNUM사용
1. 프로시져명 : PROC_MEM_PTOP
2. 매개변수 : 입력용 : 년도 2005
             출력용 : 회원명, 구매액
             
CREATE OR REPLACE PROCEDURE PROC_MEM_PTOP
    P_YEAR IN CART.CART_NO%TYPE,
    P_NAME OUT MEMBER.MEM_NAME%TYPE,
    P_AMT OUT VARCHAR
AS
BEGIN
    SELECT A.MEM_NAME, C.PROD_PRICE
    INTO P.NAME, P.AMT
    FROM A.MEMBER, B.CART, C.PROD
    WHERE A.MEMBER_ID = B.CART_MEMBER
        AND B.CART_PROD = C.PROD_ID;
END;
ACCEPT P_YEAR PROMPT '년도 : '
DECLARE 
    V_NAME MEMBER.MEM_NAME%TYPE;
    V_AMT 

 **2005년도 회원별 구매금액**   --------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PROC_MEM_PTOP(
    P_YEAR IN CHAR,  --년도는 CART테이블에서 구매한저보르 꺼내는데 사용 /'2005' 숫자 OR 문자 상관없음
    P_NAME OUT MEMBER.MEM_NAME%TYPE, --확실하게 알고 있을때
    P_AMT OUT NUMBER) --확실하지 않기 때문에 숫자 NUMBER
AS
BEGIN
--회원아이디 // 구매금액 -- 단가 구해야함 카드테이블엔 단가 없음 PROD로 가야함 (QTY는 상품갯수)
    SELECT M.MEM_NAME, A.AMT INTO P_NAME, P_AMT
    FROM (SELECT C.CART_MEMBER AS MID, SUM(C.CART_QTY * P.PROD_PRICE) AS AMT 
          FROM CART C, PROD P
          WHERE C.CART_PROD = P.PROD_ID
              AND SUBSTR(C.CART_NO,1,4) = P_YEAR
          GROUP BY C.CART_MEMBER
          ORDER BY 2 DESC)A, MEMBER M  --2 :SUM(A.CART_QTY*B.PROD_PRICE)
    WHERE M.MEM_ID = A.MID --이름 갖고오고 싶어서 조인
        AND ROWNUM = 1;
--위과정을 OUT매개 변수에 넣어줘야함
END;
---------------------------------------------------------------------------------------------------------
DECLARE 
    V_NAME MEMBER.MEM_NAME%TYPE;
    V_AMT NUMBER :=0;
BEGIN
    PROC_MEM_PTOP('2005', V_NAME, V_AMT);
    
    DBMS_OUTPUT.PUT_LINE('회원명 : ' || V_NAME);
    DBMS_OUTPUT.PUT_LINE('구매금액 : ' ||TO_CHAR(V_AMT,'99,999,999'));
END;

-----------------------------------------------------------------------------------------
문제] 2005년도 구매금액이 없는 회원을 찾아 회원테이블(MEMBER)의 삭제 여부 컬럼(MEM_DELETE)의 값을 'Y'로 변경 하는 프로시져를 작성하시오
SELECT *
FROM MEMBER;

SELECT * FROM EMPLOYEES;

커서에 가져온 회원번호를멤버테이블의 회원번호를 비교에서 Y로 업데이트 시킴
실행하는 것은 구매금액이 없느 회원을 찾아서 넘겨줘야함

(프로시져 생성 : 입력받은 회원번호로 해당 회원의 삭제 여부 컬럼값을 변경)
CREATE OR REPLACE PROCEDURE PROC_MEM_UPDATE(
    P_MID IN MEMBER.MEM_ID%TYPE)
AS

BEGIN
    UPDATE MEMBER
        SET MEM_DELETE = 'Y'
    WHERE MEM_ID = P_MID;
    COMMIT;
END;
        
--2)프로시져 실행영영
--(구매금액이 없는 회원) 카트테이블에 해당된 값이 없는 것


--<구매사실이 없는사람>
DECLARE
    CURSOR CUR_MID
    IS
    SELECT MEM_ID
        FROM MEMBER
    WHERE MEM_ID NOT IN (SELECT CART_MEMBER --[구매한사람 나열]  
                             FROM CART 
                            WHERE CART_NO LIKE '2005%');
BEGIN
FOR REC_MID IN CUR_MID LOOP
    PROC_MEM_UPDATE(REC_MID.MEM_ID);
END LOOP; --커서에 생성된 데이터가 하나씩 처리됨
END;