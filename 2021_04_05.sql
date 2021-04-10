2021-04-05-01) 인덱스 객체
(사용형식)
CREATE [UNIQUE | BITMAP] INDEX 인덱스명
    ON 테이블명(컬럼명1,[컬럼명2,...])[ASC | DESC] 
   
   --부모의 생존이 자식의 생존에 영향을 미침
   --부모테이블의 기본키가 자식테이블의 외래키가 됨
   --비식별관계 - 효율성 측면에서 조인현상을 많이 발생해도 무방/ WHERE 절이 길어져도 좋다 - 식별관계 
   
   EX)상품테이블에서 상품명으로 NORMAL INDEX를 구성하시오
   --PROD NAME을 가지고 인덱스 만들기
   CREATE INDEX IDX_PROD_NAME
    ON PROD(PROD_NAME);
    
    EX) 장바구니테이블에서 장바구니번호 중 3번째에서 6글자로 인덱스를 구성하시오
    -- 글자수 변경 SUBSTR
    CREATE INDEX IDX_CART_NO
        ON CART(SUBSTR(CART_NO,3 , 6));
        
    => 세부정보 FUNCTION-BASED NORMAL (:인덱스를 만들때 함수 사용(함수기반)) 
  
  **인덱스의 재구성**
  - 데이터 테이블을 다른 테이블스페이스로 이동시킨 후 
  - 자료의 삽입과 삭제 동작 후
  
  EX) 
  ALTER INDEX 인덱스명 REBUILD; (인덱스 파일이 최신상태로 변경됨)
  
  2021-04-05) PL/SQL
  - PROCEDURAL LANGUAGE sql의 약자
  - 표준 sql에 절차적 언어의 기능(비교, 반복이 변수 등)이 추가
  - 블록(block) 구조로 구성
  - 미리 컴파일되어 실행 가능한 상태로 서버에 저장되어 필요시 호출되어 사용됨
  - 모듈화, 캡술화 기능 제공
  - Anonymous block, Stored procedure, User Defined Function, Package, Trigger 등으로 구성
  
  1. 익명블록 (호출불가능)
  - pl/sql의 기본 구조
  - 선언부와 실행부로 구성
  (구성형식)
DECLARE
   --선언영역
   --변수, 상수, 커서 선언
BEGIN
   --실행영역
   --BUSINESS LOGIC 처리
   
   [EXCEPTION
        예외처리명령;
    ]
END;    

--익명블록을 사용하는 방법
EX) 키보드로 2-9 사이의 값을 입력 받아 구 수에 해당하는 구구단을 작성하시오
ACCEPT P_NUM PROMPT '수 입력(2~9) : '  --(키보드로 입력받을때사용하는 명령어 ACCEPT) PROMPT 뒤는 제목 
DECLARE --변수 : V_ / 매개변수 : P_
    V_BASE NUMBER := TO_NUMBER('&P_NUM'); -- P_NUM 을 가져와라라는 뜻 / 숫자로 변환 / 오라클은 숫자, 문자 둘다 초기화 시키지 않으면 NULL
    V_CNT NUMBER := 0; --초기화 됨 
    V_RES NUMBER := 0;
BEGIN
    LOOP --무한 루프
    V_CNT := V_CNT + 1; --V_CNT를 숫자로 바꿔줘야함 / 초기화 시키지 않을 경우 NULL값이여서 에러창 뜸 반드시 초기화시켜줘야함
        EXIT WHEN V_CNT> 9; -- V_CNT가 9보다 클겨우 무한 루프를 빠져나옴
        V_RES := V_BASE * V_CNT;
        
        DBMS_OUTPUT.PUT_LINE(V_BASE || '*' || V_CNT || '=' || V_RES); --결과를 내보낼때 사용됨
    END LOOP; --루프를 끝냄 (반드시 있어야함)
    
    EXCEPTION WHEN OTHERS THEN -- 자바의 EXCEPTION과 같음 (예외발생 시 예외종류 알고 싶을 때)
        DBMS_OUTPUT.PUT_LINE('예외발생' || SQLERRM); --SQPERRM : SQL에러메세지
END;

1) 변수, 상수 선언
 - 실행영역에서 사용할 변수 및 상수 선언
 (1)변수의 종류
    . SCLAR 변수 - 하나의 데이터를 저장하는 일반적 변수
    . REFERENCES 변수 - 해당 테이블의 컬럼이나 행에 대응하는 타입과 크기를 참조하는 변수
    . COMPOSITE 변수 - PL/SQL에서 사용하는 배열 변수
      RECORD TYPE 
      TABLE TYPE 변수 
    . BIND 변수 - 파라미터로 넘겨지는 IN, OUT, INOUT에서 사용되는 변수 (변수의 값을 저장하는 것 : BINDING)
     RETURN 되는 값을 전달받기 위한 변수
 (2)선언방식
    변수명 [CONSTANT] 데이터타입 [:=초기값]
    변수명 테이블명.컬럼명%TYPE [:=초기값] -> 컬럼 참조형 (테이블명과 똑같은 컬럼),
    변수명 테이블명%ROWTYPE [:=초기값]-> 행참조형 

 (3)데이터타입
 - 표준 SQL에서 사용하는 데이터 타입
 - PLS_INTEGER, BINARY_INTEGER : 2147483647 ~ 2147483648 까지 자료처리
 - BOOLEAN : TRUE, FALSE, NULL 처리
 - LONG, LONG RAW : DEPRECATED -- DEPRECATED : 쓸수있지만 기능 시스템이 종료됨

   EX)장바구니에서 2005년 5월 가장 많은 구매를 한(구매금액 기준) 회원정보를 조회하시오(회원번호, 회원명, 구매금액합)
    
    SELECT A.cart_member AS 회원번호, B.mem_name AS 회원명, SUM(C.prod_price * A.cart_qty) AS 구매금액
    FROM cart A, member B, prod C
    WHERE A.cart_member = B.mem_id
    AND A.cart_prod = C.prod_id
    GROUP BY A.cart_member, B.mem_name
    ORDER BY 3 DESC;    --가장많이 구매한 사람 찾을 때 사용  

    (서브쿼리)
    SELECT D.MID AS 회원번호, B.mem_name AS 회원명, D.AMT AS 구매금액합
    FROM  
    (SELECT A.cart_member AS MID, SUM(C.prod_price * cart_qty) AS AMT  -----WHY? 왜 서브쿼리를 만들때 멤버 테이블만 따로 뺐는지 알기
        FROM cart A, prod C
        WHERE A.cart_prod = c.prod_id
        GROUP BY A.cart_member
        ORDER BY 2 DESC) D, member B
    WHERE D.MID = B.mem_id
     AND ROWNUM =1;
    구매금액 구하기 위한 것 : 수량 , 단가 (단가는 prod테이블에 있음)
    
    (뷰로 만들기)
    CREATE OR REPLACE VIEW V_MAXAMT
    AS  
    SELECT D.MID AS 회원번호, B.mem_name AS 회원명, D.AMT AS 구매금액합
    FROM  
    (SELECT A.cart_member AS MID, SUM(C.prod_price * cart_qty) AS AMT
        FROM cart A, prod C
        WHERE A.cart_prod = c.prod_id
        GROUP BY A.cart_member
        ORDER BY 2 DESC) D, member B
    WHERE D.MID = B.mem_id
     AND ROWNUM =1;
     
    SELECT * FROM V_MAXAMT;
    --(group by문의 사용 여부는 select 절에 달려있음)

    (익명블록)
DECLARE
    V_MID V_MAXAMT.회원번호%TYPE; --외부로 부터 가지고옴 / V_MID와 V_MAXAMT 뷰의 회원번호와 같은 타입으로 설정하라는 뜻
    V_NAME V_MAXAMT.회원명%TYPE;  
    V_AMT V_MAXAMT.구매금액합%TYPE;
    V_RES VARCHAR2(100); --자동으로 NULL로 초기화되어서 초기화 안해도됨
BEGIN  
    SELECT 회원번호, 회원명, 구매금액합 INTO V_MID, V_NAME, V_AMT --SELECT 뒤에있는 컬럼이 INTO 뒤에 있는 변수에 들어있다는 뜻 
        FROM V_MAXAMT;
        
    V_RES:=V_MID || ',' || V_NAME ||',' || TO_CHAR(V_AMT,'99,999,999');
    
    DBMS_OUTPUT.PUT_LINE(V_RES);
END;

SELECT *
FROM V_MAXAMT
(상수사용예)
키보드로 수하나를 입력 받아 그 값을 반지름으로 하는 원의 넓이를 구하시오

ACCPET P_NUM PROMPT '원의 반지름 : '
DECLARE 
    V_RADIUS NUMBER := TO_NUMBER('&P_NUM');
    V_PI CONSTANT NUMBER := 3.1415926;  --초기값을 집어넣는 문이 와야함
    V_RES NUMBER := 0;
BEGIN
    V_RES := V_RADIUS * V_RADIUS * V_PI;
    DBMS_OUTPUT.PUT_LINE('원의 너비 = ' || V_RES);
END;