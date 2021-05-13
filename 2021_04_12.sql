문장단위 트리거 예) 상품분류테이블에 자료를 삽입하시오 자료 삽입 후 '상품분류코드가 추가 되었습니다'라는 메시지를 트리거를 이용하여출력하시오
[자료]         --               AFTER INSERT ON LPROD            BEGIN DBMS_OUTPUT.PUT_LINE('상품분류코드가 추가되었습니다.'); 
.lprod_gu : 'p601'
.lprod_nm : '신선식품'

(트리거 생성)
CREATE OR REPLACE TRIGGER TG_LPROD_INSERT
    AFTER INSERT ON LPROD  --행단위 트리거이려면 AFTER 부분에 'FOR EACH ROW 써야함
BEGIN
    DBMS_OUTPUT.PUT_LINE('상품분류코드가 추가되었습니다.'); 
END;
--헤더부분 :상품분류테이블
(이벤트만들기)
INSERT INTO LPROD
VALUES (11,'P601','신선식품'); 
SELECT * FROM LPROD;--리로드와 같은 기능

---삭제
DELETE LPROD
WHERE LPROD_NM = '신선식품'

--4월 16일날 3건 발생마다 처리 카드번호가 여러개 => 여러상품이 담겨있음 산 물품마다 UPDATE하는 것 => 행단위 트리거
(사용예) 매입테이블에서 2005년 4월16일 상품 'P101000001'을 매입한 다음 재고수량을 UPDATE하시오 --(INSERT와 UPDATE 동시에)
[매입정보]
1. 상품코드 : 'P10100001'
2. 날짜 '2005-04-16'
3. 매입수량 : 5
4. 매입단가 : 210000

(트리거 생성 (1)) --  트리거 약어/해당테이블/해당명령어   //매입장에 INSERT
CREATE OR REPLACE TRIGGER TG_REMAIN_UPDATE
    AFTER INSERT OR UPDATE OR DELETE ON BUYPROD  -- 어떤 이벤트를 쓸지 모를 때 OR로 연결 //BUYPROD 제품매입했을때 매입 정보가 저장되는 곳(매입장) (CART = 매출)
    FOR EACH ROW  --외부로부터 들어있는 값을 꺼낼수 없음 
BEGIN
    UPDATE REMAIN
        SET (REMAIN_I, REMAIN_J_99, REMAIN_DATE) = ( 
            SELECT REMAIN_I + :NEW.BUY_QTY, REMAIN_J_99 + :NEW.BUY_QTY,'20050416'   -- REMAIN_I +: NEW.BUY_QTY =현재수량 + 추가된 수량
            FROM REMAIN
            WHERE REMAIN_YEAR = '2005'
              AND PROD_ID = :NEW.BUY_PROD) --NEW는 행전체를 가르킴 (컬럼지칭은 .컬럼명)
    WHERE  REMAIN_YEAR = '2005' --업데이트 대상을 선택하는것
     AND PROD_ID = :NEW.BUY_PROD;
END;
----------------------컴파일 해주기---------------------------
INSERT INTO BUYPROD
    VALUES(TO_DATE('20050416'), 'P101000001', 5, 210000);
-----------------------컴파일 후 인서트문 실행 ----------------

SELECT * FROM REMAIN;


--해당테이블안에 존재하는 자료를 가지고 이벤트하면 ALL VIEW / 없는 자료를 신규로 집어넣는것 :NEW / 
--존재하는 자료보다 UPDATE하는 자료가 더 많으면 더많은 수대로 NEW를 써줌

** 트리거
    - 데이터의 무결성 제약을 강화
    - 트리거 내부에는 트렌젝션 제어문(COMMIT, ROLLBACK, SAVEPOINT 등)을 사용 할 수 없음
    - 트리거 내부에 사용되는 PROCEDURE, FUNCTION 에서도 트렌젝션 제어문을 사용 할 수 없음
    -LONG, LONG ROW 등의 변수 선언 사용할 수 없음
**트리거 의사레코드
1) :NEW = INSERT, UPDATE 에서 사용,
         데이터가 삽입(갱신)될 떄 새롭게 들어오는 자료
         DELETE 시에는 모두 NULL로 SETTING
2):OLD = DELETE, UPDATE 에서 사용,
         데이터가 삭제(갱신)될 떄 새롭게 들어오는 자료
         INSERT 시에는 모두 NULL로 SETTING 
**트리거 함수
- 트리거를 유발시킨 DML을 구별하기 위해 사용
--------------------------------------------------------------
    함수          의미
--------------------------------------------------------------
  INSERTING     트리거의 EVENT 가 INSERT 이면 참(TRUE) 반환
  UPDATING      트리거의 EVENT 가 UPDATE 이면 참(TRUE) 반환
  DELETING      트리거의 EVENT 가 DELETE 이면 참(TRUE) 반환
  
  EX) 장바구니테이블에 신규 판매자료가 삽입될때 재고를 처리하는 트리거를 작성하시오
 -- 회원이 구매한 상품마다 CART_QTY에 저장됨
CREATE OR REPLACE TRIGGER TG_REMAIN_CART_UPDATE
    AFTER INSERT OR UPDATE OR DELETE ON CART
    FOR EACH ROW
DECLARE 
    V_QTY CART.CART_QTY%TYPE;
    V_PROD PROD.PROD_ID%TYPE;
BEGIN
    IF INSERTING THEN
     V_QTY:= :NEW.CART_QTY;  
     V_PROD:= :NEW.CART_PROD; 
    ELSIF UPDATING THEN
     V_QTY := :NEW.CART_QTY - :OLD.CART_QTY; --10 -5 = 5 OLD// NEW = -3  NEW-(-OLD) //증가되어진 수량
     V_PROD := :NEW.CART_PROD;
    ELSE
      V_QTY:= -(:OLD.CART_QTY); 
      V_PROD:= :OLD.CART_PROD;
    END IF;
    UPDATE REMAIN
        SET REMAIN_O = REMAIN_O + V_QTY,
            REMAIN_J_99 = REMAIN_J_99 - V_QTY,
            REMAIN_DATE = SYSDATE
    WHERE REMAIN_YEAR = '2005' 
      AND PROD_ID = V_PROD;
      
      DBMS_OUTPUT.PUT_LINE(V_PROD || '상품 재고수량 변동 : ');
END;

(EVENT : INSERT인 경우)
a001회원이 상품 'P101000003'을 5개 구매한 경우
INSERT INTO CART
VALUES('a001','2021041200001', 'P101000003', 5);

(EVENT : UPDATE인 경우)
a001회원이 상품 'P101000003'을 5개 구매한 경우
UPDATE CART
    SET CART_QTY = 7
WHERE CART_NO = '2021041200001'
  AND CART_PROD = 'P101000003' ;

COMMIT;

(DELETE가 EVENT 인경우)

DELETE CART
WHERE CART_NO = '2021041200001'
  AND CART_PROD = 'P101000003';
SELECT *FROM REMAIN
WHERE REMAIN_YEAR = '2005'
    AND PROD_ID = 'P101000003'  --REMAIN_O에 변화가 있어야함

UPDATE PROD
    SET PROD_MILEAGE = 19
WHERE PROD_ID = 'P202000001';

UPDATE PROD
    SET PROD_MILEAGE = ROUND(PROD_PRICE * 0.001);
COMMIT;
-----------------------------------------------------------------------------------------------------------------
문제] 'f001'회원이 오늘 상품'P202000001'을 15개 구매했을때 이정보를 CART테이블에 저장한 후 재고수불테이블과 회원테이블(마일리지)을
    변경하는 트리거를 작성하시오
CREATE OR REPLACE TRIGGER TG_REMAIN_CART_UPDATE
    AFTER INSERT OR UPDATE OR DELETE ON CART
    FOR EACH ROW
DECLARE 
    V_QTY CART.CART_QTY%TYPE;
    V_PROD PROD.PROD_ID%TYPE;
BEGIN
    IF INSERTING THEN
     V_QTY:= :NEW.CART_QTY;  
     V_PROD:= :NEW.CART_PROD; 
    ELSIF UPDATING THEN
     V_QTY := :NEW.CART_QTY - :OLD.CART_QTY; --10 -5 = 5 OLD// NEW = -3  NEW-(-OLD) //증가되어진 수량
     V_PROD := :NEW.CART_PROD;
    ELSE
      V_QTY:= -(:OLD.CART_QTY); 
      V_PROD:= :OLD.CART_PROD;
    END IF;
    UPDATE REMAIN
        SET REMAIN_O = REMAIN_O + V_QTY,
            REMAIN_J_99 = REMAIN_J_99 - V_QTY,
            REMAIN_DATE = SYSDATE
    WHERE REMAIN_YEAR = '2005' 
      AND PROD_ID = V_PROD;
      
      DBMS_OUTPUT.PUT_LINE(V_PROD || '상품 재고수량 변동 : ');
END;

INSERT INTO CART
VALUES('f001','2021041200001', 'P202000001', 15);

UPDATE CART
    SET CART_QTY = 7
WHERE CART_NO = '2021041200001'
  AND CART_PROD = 'P202000001' ;

ALTER TABLE TB_JDBC_BOARD
    RENAME COLUMN COLUMN5 TO REG_DATE;

SELECT *
FROM TB_JDBC_BOARD
COMMIT;