2021-04-06) 
<<커서(CURSOR)>>
 이름이 없는 커서는 오픈되자마자 클로즈됨 = 접근불가
 - 커서는 쿼리문의 영향을 받은 행들의 집합
 - 묵시적커서(IMPLICITE), 명시적커서(EXPLICITE)로 구분
 - 커서의 선언은 선언부에서 수행
 - 커서의 OPEN, FETCH,CLOSE 는 실행부에서 기술
 
 1) 묵시적 커서
 . 이름이 없는 커서
 . 항상 CLOSE 상태이기 때문에 커서내로 접근 불가능
 (커서속성) 커서명이 있어야 묵시적 커서는 하는데 이름이 없기때문에 SQL이 붙음
 -------------------------------------------------------------------------------
 속성                      의미
 -------------------------------------------------------------------------------
 SQL%ISOPEN            커서가 OPEN되었으면 참(TRUE)반환 - 묵시적커서는 항상 FALSE
 SQL%NOTFOUND          커서내에 읽을 자료가 없으면 참(TRUE)반환 
 SQL%FOUND             커서내에 읽을 자료가 남아있으면 참(TRUE)반환
 SQL%ROWCOUNT          커서내 자료의 수 반환
 -------------------------------------------------------------------------------
 2)명시적 커서
 .이름이 있는 커서
 . 생성 -> OPEN -> FETCH -> CLOSE 순으로 처리해야함 (단,FOR문은 예외)
 (FOR문이 있으면 대부분 커서도 있음)
 
 (1)생성
    (사용형식)
    CURSOR   커서명 [(매개변수 LIST /*커서에 필요한 데이터를 전달받음*/)](SELECT문의 영향을 받음/ VIEW 와 비슷함)
    IS
        SELECT문;
    
EX)상품매입테이블(BUYPROD)에서 2005년 3월 상품별 매입현황(상품코드, 상품명, 거래처명, 매입수량)
    을 출력하는 쿼리를 커서를 사용하여 작성하시오                                    QTY
    SELECT *
    FROM BUYER
    SELECT *
    FROM PROD;
(1) 상품별 2005년 3월 매입현황 출력 (상품코드 + 매입수량) 
       상품코드 => 상품명(RPOD_NAME), 거래처명(BUYER_NAME)을 구할수 있음
    P202000001                      P20201
DECLARE --선언해준거임(익명블록)
    V_PCODE PROD.PROD_ID%TYPE;
    V_PNAME PROD.PROD_NAME%TYPE;
    V_BNAME BUYER.BUYER_NAME%TYPE;
    V_AMT NUMBER := 0; --반드시 0으로 초기화 시켜야함
    
   
    CURSOR CUR_BUY_INFO IS  
        SELECT BUY_PROD, SUM(BUY_QTY) AS AMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050301' AND '20050331'--날짜타입의 구간은 BETWEEN을 써줘야함
        GROUP BY BUY_PROD;
        
BEGIN

END;

(2)OPEN문
    - 명시적 커서를 사용하기전 커서를 OPEN 
    (사용형식)
    OPEN 커서면 [(매개변수list)]; --커서를 만들때 매개변수list에 값을 지정해서 커서선언문으로 전달되도록 만들어짐
    
    DECLARE
    V_PCODE PROD.PROD_ID%TYPE;
    V_PNAME PROD.PROD_NAME%TYPE;
    V_BNAME BUYER.BUYER_NAME%TYPE;
    V_AMT NUMBER := 0; 
    
   
    CURSOR CUR_BUY_INFO IS  
        SELECT BUY_PROD, SUM(BUY_QTY) AS AMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050301' AND '20050331'
        GROUP BY BUY_PROD;
        
BEGIN
OPEN CUR_BUY_INFO;

END;

(3) FETCH 문
    - 커서 내의 자료를 읽어오는 명령 (SELECT 절과 비슷)
    - 보통 반복문 내에 사용
    (사용형식)
    FETCH 커서명 INTO 변수명 
    . 커서내의 컬럼값을 INTO 다음 기술된 변수에 할당
    
    DECLARE
    V_PCODE PROD.PROD_ID%TYPE;
    V_PNAME PROD.PROD_NAME%TYPE;
    V_BNAME BUYER.BUYER_NAME%TYPE;
    V_AMT NUMBER := 0; 
    
   
    CURSOR CUR_BUY_INFO IS  
        SELECT BUY_PROD, SUM(BUY_QTY) AS AMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050301' AND '20050331'
        GROUP BY BUY_PROD;
        
BEGIN
    OPEN CUR_BUY_INFO;
    LOOP  --반복명령
        FETCH CUR_BUY_INFO INTO V_PCODE, V_AMT; 
        EXIT WHEN CUR_BUY_INFO%NOTFOUND;
            SELECT PROD_NAME, BUYER_NAME INTO V_PNAME, V_BNAME
            FROM PROD, BUYER
            WHERE PROD_ID = V_PCODE
            AND PROD_BUYER = BUYER_ID;
            DBMS_OUTPUT.PUT_LINE('상품코드 : ' || V_PCODE);
            DBMS_OUTPUT.PUT_LINE('상품명 : ' || V_PNAME);
            DBMS_OUTPUT.PUT_LINE('거래처명 : ' || V_BNAME);
            DBMS_OUTPUT.PUT_LINE('매입수량 : ' || V_AMT);
            DBMS_OUTPUT.PUT_LINE('-------------------------');
         
        END LOOP;   
        DBMS_OUTPUT.PUT_LINE('자료수 : ' || CUR_BUY_INFO%ROWCOUNT); --전체자료수 확인
        
        CLOSE CUR_BUY_INFO;
END;

EX) 상품분류코드 'P102'에 속한 상품의 상품명, 매입가격, 마일리지를 출력하는 커서를 작성하시오
 (표준 SQL)
 SELECT prod_name AS 상품명, prod_cost AS 매입가격, prod_mileage AS 마일리지
 FROM prod
 WHERE prod_lgu = 'P102';
 --위에를 출력하려면 커서를 써야하고 커서를 쓸 경우 반복문을 써야함
 
 (익명블록) -- 출력되는 것들은 대부분 변수로 설정해줘야함
 ACCEPT P_LCODE PROMPT '분류코드 :'
 DECLARE 
   V_PNAME PROD.PROD_NAME%TYPE; --% TYPE => 참조하라는 뜻
   V_COST PROD.PROD_COST%TYPE;
   V_MILE PROD.PROD_MILEAGE%TYPE;
   
   CURSOR CUR_PROD_COST(P_LGU LPROD.LPROD_GU%TYPE) 
   IS 
     SELECT prod_name, prod_cost, prod_mileage
    FROM prod
    WHERE prod_lgu = P_LGU; 
BEGIN
    OPEN CUR_PROD_COST('$P_LCODE'); --내가 넘겨줄 매개변수가 나와야함 / 위에 ACCEPT를 해주어서 매개변수를 사용하지 않고 '$P_LCODE'를써줄수 있음
    DBMS_OUTPUT.PUT_LINE('상품명     '|| '          단가   ' || '마일리지');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    LOOP
        FETCH CUR_PROD_COST INTO V_PNAME, V_COST, V_MILE; 
        EXIT WHEN CUR_PROD_COST$NOTFOUND; --커서에 더이상 자료가 없을때 
        DBMS_OUTPUT.PUT_LINE(V_PNAME || '   ' || V_COST || '   ' || V_MILE());
    END LOOP;
    CLOSE CUR_PROD_COST;
END;

<<조건문>>
1. IF문
 - 개발언어의 조건문(IF문)과 동일 기능 제공
 (사용형식1)
 IF 조건식 THEN 
    명령문1;
 [ELSE
    명령문 2;]
 END IF;
 
 (사용형식2)
 IF 조건식 THEN 
    명령문1;
 ELSIF 조건식2  THEN--조건이 반복되는 경우
    명령문 2;
[ELSIF 조건식3  THEN  --위에 있는 조건식과 맞지 않을때
    명령문 3;
    .
    .
 ELSE 
    명령문 n;]
 END IF;
 (사용형식 3)  --중첩IF
  IF 조건식 THEN 
    명령문1;
    IF 조건식2  THEN --조건이 맞을때
        명령문 2;
    ELSE
        명령문 3;
    END IF;
   ELSE 명령문4  
    END IF;
 
 EX) 상품테이블에서 'P201'분류에 속한 상품둘의 평균단가를 구하고 해당 분류에 속한 상품들의 판매단가를 비교하여 같으면 '평균가격 상품',
    적으면 '평균가격 이하 상품', 많으면 '평균가격 이상 상품'을 비고난에 출력하시오 출력은 상품코드, 상품명, 가격, 비고이다.
    
DECLARE 
    V_PCODE PROD.PROD_ID%TYPE;
    V_PNAME PROD.PROD_NAME%TYPE;
    V_PRICE PROD.PROD_PRICE%TYPE;
    V_REMARKS VARCHAR2(50);
    V_AVG_PRICE PROD.PROD_PRICE%TYPE; --평군가격 보관변수 
BEGIN
    SELECT PROD_ID, PROD_NAME, PROD_PRICE INTO V_PCODE, V_PNAME, V_PRICE
    FROM PROD
    WHERE PROD_LGU = 'P201';
END;    --오류뜸  (변수에 넣어주려고 보니 하나이상의 데이터가 들어가서)변수는 단하나만 가능 => 커서로 오류복구

DECLARE 
    V_PCODE PROD.PROD_ID%TYPE;
    V_PNAME PROD.PROD_NAME%TYPE;
    V_PRICE PROD.PROD_PRICE%TYPE;
    V_REMARKS VARCHAR2(50);
    V_AVG_PRICE PROD.PROD_PRICE%TYPE; --평균가격 보관변수 
    
    CURSOR CUR_PROD_PRICE
    IS
     SELECT PROD_ID, PROD_NAME, PROD_PRICE
     FROM PROD
     WHERE PROD_LGU = 'P201';
BEGIN
 SELECT ROUND(AVG(PROD_PRICE)) INTO V_AVG_PRICE
    FROM PROD
    WHERE PROD_LGU = 'P201';
    
    OPEN CUR_PROD_PRICE;
    LOOP
    FETCH CUR_PROD_PRICE INTO V_PCODE, V_PNAME ,V_PRICE;
    EXIT WHEN CUR_PROD_PRICE%NOTFOUND;
    IF V_PRICE > V_AVG_PRICE THEN 
        V_REMARKS := '평균가격 이상 상품';
    ELSIF V_PRICE < V_AVG_PRICE THEN 
        V_REMARKS := '평균가격 이하 상품';
    ELSE 
    V_REMARKS := '평균가격 상품';
    END IF;
    DBMS_OUTPUT.PUT_LINE(V_PCODE ||  ', ' || V_PNAME || ', ' || V_PRICE || ', ' || V_REMARKS);
 END LOOP;
 CLOSE CUR_PROD_PRICE;
END;

2.CASE 문  --전기요금/ 수도요금 계산시 
 - JAVA의 SWITCH CASE 문과 유사기능 제공
 - 다방향 분기 기능 제공
 (사용형식)
 CASE 변수명|수식 
    WHEN 값1 THEN  --WHEN 과 THEN이같으면 명령1 
        명령1;
    WHEN 값2 THEN  --위식이 맞지 않으면 값2이로 와서 실행
        명령2;
        :
    ELSE
        명령n;
 END CASE;
 
 CASE WHEN 조건식1 THEN -- 조건식 참이면 명령1 아니면 명령 2 ...
            명령1;
      WHEN 조건식2 THEN
            명령2;
            .
            .
      ELSE
            명령n;
 END CASE;
 
EX) 수도요금 계산
    물 사용요금(톤당 단가)
    1 - 10 : 350원
    11 - 20 : 550원
    21 - 30 : 900원
    그이상 :1500원
    
    하수도 사용료 
    사용량 * 450원
    
26톤 사용 시 요금
    (10 * 350) + (10 * 550) + (6 * 900) + (26 * 450) = 
        3500 + 5500 + 5400 + 11,700 = 26,100원
        
ACCEPT P_AMOUNT PROMPT '물 사용량 : ' -- 물사용량 입력받는 것
DECLARE
    V_AMT NUMBER := TO_NUMBER('&P_AMOUNT');
    V_WA1 NUMBER := 0; --물 사용요금
    V_WA2 NUMBER := 0; --하수도 사용료
    V_HAP NUMBER := 0; --요금합계
BEGIN
    CASE WHEN V_AMT BETWEEN 1 AND 10 THEN
            V_WA1 := V_AMT * 350;
         WHEN V_AMT BETWEEN 11 AND 20 THEN
            V_WA1 := 3500 + (V_AMT-10) * 550;
        WHEN V_AMT BETWEEN 21 AND 30 THEN
            V_WA1 := 3500 + 5500 + (V_AMT-20) * 900;
        ELSE
            V_WA1 := 3500 + 5500 + 9000 +(V_AMT-30) * 1500;
    END CASE;
    V_WA2 := V_AMT * 450;  
    V_HAP := V_WA1 + V_WA2;
    
    DBMS_OUTPUT.PUT_LINE(V_AMT || '톤의 수도요금 : ' || V_HAP);
END;