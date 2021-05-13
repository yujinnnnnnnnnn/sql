2021-04-13
패키지(Package)
- 논리적 연관성 있는 PL/SQL타입, 변수, 상수, 함수, 프로시져 등의 항목들을 묶어 놓은 것
- 모듈화, 캡슐화 기능 제공
- 관련성있는 서브프로그램의 집합으로 disk I/O 이 줄어 효율적
1.PACKAGE 구조
- 선언부와 본문부로 구성
1) 선언부(프로토 타입)
 . 패키지에 포함될 변수, 프로시져, 함수 등을 선언 
 
 (사용형식) --선언부이기 때문에 BIGIN(실행)은 없음// 자바의 추상클래스같은 존재 
 CREATE [OR REPLACE] PACKAGE 패키지명
 IS|AS --사용자 변수를 만들어주는 구문
    TYPE 구문;
    상수[변수] 선언문;
    커서;
    함수|프로시져 프로토타입;--여러함수 나올 수 있음(필요함수 기술)
             :
 END 패키지명;
 
 2)본문부 --자바의 자식클래스같은 존재
  . 선언부에서 정의한 서브프로그램의 구현 담당
  (사용형식)
  CREATE [OR REPLACE] PACKAGE BODY 패키지명
  IS|AS
    상수, 커서, 변수 선언;
    
    FUNCTION 함수명(매개변수 list)
        RETURN 타입명 --여기까지 선언
    BEGIN
        PL/SQL명령(들);
        RETURN expr;
    END 함수명;
       :
       
END 패키지명;

사용예)상품테이블에 신규 상품을 등록하는 업무를 패키지로 구성하시오 (신규상품등록 1) 해당제품이 어느분륭 ㅔ속하는지알아야함 => 상품코드앞자리 분류코드를 알아야 해당상품코드를 가져올수 있음)
                                                                        2)분류코드내에 상품코드의 제일큰값의 상품코드를 알아야함 -> 상품배정을 위해
                                                                          분류코드확인후 분류코드 없을 시 분류코드하나 생성 분류코드 있을시 분류코드반환
                                                                          상품코드 생성해서 반환받아야함
                                                                         3) 상품테이블에 상품코드 집어넣어야함
                                                                        4) 재고수불테이블에 
  --분류코드는 분류테이블중 하나를 가져오는 것이기 때문에 함수 사용 아님                                                                  
  분류코드 확인 -> 상품코드생성 -> 상품테이블 등록 -> 재고수불테이블 등록
= 분류코드 반환때문(함수)->  생성코드 반환(함수)->  반환값 없기때문(프로시져)-> 반환값 없기때문 (프로시져)
(분류코드가없을시 생성(프로시져)
분류코드 있을시 가져오는 것이기때문에 함수사용 안해도됨)

(패키지 선언부)
CREATE OR REPLACE PACKAGE PROD_NEWITEM_PKG
IS
    V_PROD_LGU LPROD.LPROD_GU%TYPE;--(변수 나중 추가)
   
    --분류코드 생성
    FUNCTION FN_INSERT_LPROD(
    P_GU IN LPROD.LPROD_GU%TYPE,
    P_NM IN LPROD.LPROD_NM%TYPE)
    RETURN LPROD.LPROD_GU%TYPE;
    
     --상품코드 생성 및 상품등록 (,PROD 테이블에 NO인것들)
    PROCEDURE PROC_CREATE_PROD_ID(
    P_GU IN LPROD.LPROD_GU%TYPE,
    P_NAME IN PROD.PROD_NAME%TYPE,
    P_BUYER IN PROD.PROD_BUYER%TYPE,
    P_COST IN NUMBER,
    P_PRICE IN NUMBER,
    P_SALE IN NUMBER,
    P_OUTLINE IN PROD.PROD_OUTLINE%TYPE,
    P_IMG IN PROD.PROD_IMG%TYPE,
    P_TOTALSTOCK IN PROD.PROD_TOTALSTOCK%TYPE,
    P_PROPERSTOCK IN PROD.PROD_PROPERSTOCK%TYPE,
    P_ID OUT PROD.PROD_ID%TYPE);
    
    --재고수불테이블 삽입
  PROCEDURE PROC_INSERT_REMAIN(
    P_ID IN PROD.PROD_ID%TYPE,
    P_AMT NUMBER); --해당상품 입고받은 기초재고=매입수량=재고수량(현재)
    
END PROD_NEWITEM_PKG;

(패키지 본문 생성)
CREATE OR REPLACE PACKAGE BODY PROD_NEWITEM_PKG--본문부와 선언부 이름이 달라야함
IS
  FUNCTION FN_INSERT_LPROD(
    P_GU IN LPROD.LPROD_GU%TYPE,
    P_NM IN LPROD.LPROD_NM%TYPE)
    RETURN LPROD.LPROD_GU%TYPE
  IS 
    V_ID  NUMBER:=0;
  BEGIN
    SELECT MAX(LPROD_ID)+1 INTO V_ID --V_ID에 들어감
      FROM LPROD;
    INSERT INTO LPROD
      VALUES(V_ID,P_GU,P_NM);
    RETURN P_GU;   ----분류테이블에 삽입된 P_GU가 반환되어짐
  END;    
  
     --상품코드 생성 및 상품등록 (,PROD 테이블에 NO인것들)
    PROCEDURE PROC_CREATE_PROD_ID(
    P_GU IN LPROD.LPROD_GU%TYPE,
    P_NAME IN PROD.PROD_NAME%TYPE,
    P_BUYER IN PROD.PROD_BUYER%TYPE,
    P_COST IN NUMBER,
    P_PRICE IN NUMBER,
    P_SALE IN NUMBER,
    P_OUTLINE IN PROD.PROD_OUTLINE%TYPE,
    P_IMG IN PROD.PROD_IMG%TYPE,
    P_TOTALSTOCK IN PROD.PROD_TOTALSTOCK%TYPE,
    P_PROPERSTOCK IN PROD.PROD_PROPERSTOCK%TYPE,
    P_ID OUT PROD.PROD_ID%TYPE) --상품코드를 넘겨줄 공간
  IS
    V_PID PROD.PROD_ID%TYPE;
    V_CNT NUMBER := 0;
  BEGIN
    SELECT COUNT(*) INTO V_CNT  --분류코드를 갖고있는 상품의 갯수를 샘
    FROM PROD
    WHERE PROD_ID LIKE P_GU || '%';
    
    IF V_CNT = 0 THEN
    V_PID := P_GU || '000001';
    ELSE
   SELECT 'P'||TO_CHAR(SUBSTR(A.MNUM,2)+1) INTO V_PID
        FROM (SELECT MAX(PROD_ID) AS MNUM
                FROM PROD
               WHERE PROD_LGU=P_GU) A; --넘겨받은 분류코드를 'P202'에 넣어줌
    END IF;
    P_ID := V_PID;
     INSERT INTO PROD(PROD_ID,PROD_NAME,PROD_LGU,PROD_BUYER,PROD_COST,
                     PROD_PRICE,PROD_SALE,PROD_OUTLINE,PROD_IMG,
                     PROD_TOTALSTOCK,PROD_PROPERSTOCK)
      VALUES(V_PID,P_NAME,P_GU,P_BUYER,P_COST,P_PRICE,P_SALE,
             P_OUTLINE,P_IMG,P_TOTALSTOCK,P_PROPERSTOCK); 
  END;
  
    --재고수불테이블 삽입 (상품코드와 )
  PROCEDURE PROC_INSERT_REMAIN(
    P_ID IN PROD.PROD_ID%TYPE,
    P_AMT NUMBER)
  IS
  BEGIN
    INSERT INTO REMAIN(REMAIN_YEAR,PROD_ID,REMAIN_J_00,REMAIN_I,
                       REMAIN_J_99,REMAIN_DATE)
      VALUES('2005',P_ID,P_AMT,P_AMT,P_AMT,SYSDATE);                 
  END;
END PROD_NEWITEM_PKG;    
--------------------------컴파일 시키기 -----------------------------------

(입고상품의 분류코드가 p202인 경우 상품코드)
SELECT 'P' ||TO_CHAR(SUBSTR(A.MNUM,2)+1) --TO_CHAR 안하면 오라클은 숫자우선이여서 'P'를 숫자로 형변환하려고해서 오류남
FROM (SELECT MAX(PROD_ID) AS MNUM
        FROM PROD
      WHERE PROD_LGU = 'P202') A; --여기에 +1 하면 신규상품코드가 만들어짐
--서브쿼리사용하는 이유 최대값의 +1을 하기위해 그냥 +1을 해버리면 P 문자열이 들어있어서 안됨

(실행)
(신규분류코드 사용하는 경우)
DECLARE
  V_LGU LPROD.LPROD_GU%TYPE;
  V_PID PROD.PROD_ID%TYPE;
BEGIN
  V_LGU:=PROD_NEWITEM_PKG.FN_INSERT_LPROD('P701','농축산물'); --분류코드 반환
  PROD_NEWITEM_PKG.PROC_CREATE_PROD_ID(V_LGU,'소시지','P20101',10000,
     13000,11000,' ',' ',0,0,V_PID); 
  PROD_NEWITEM_PKG.PROC_INSERT_REMAIN(V_PID,10); --(상품코드, 수량)
END;
-- 헤더와 실행부분의 분류코드와 실행부분내용(갯수, 타입)이 같아야함
-------------------------실행-------------------------------
