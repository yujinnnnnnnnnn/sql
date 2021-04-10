USER DEFINED FUNCTION
- 사용자가 정의한 함수
- 반환값이 존재 --SELECT 문의 SELECT절과 WHERE 절에 사용가능
-자주사용되는 복잡한 QUERY등을 모듈화 시켜 컴파일 한후 호출하여 사용
(사용형식)
CREATE [OR REPLACE] FUNCTION 함수명(FN_~) [(
    매개변수 [IN | OUT | INOUT] 데이터타입 [{:=|DEFAULT} expr][,]
                             :
    매개변수 [IN | OUT | INOUT] 데이터타입 [{:=|DEFAULT} expr])]
    RETURN 데이터타입
AS|IS
    선언영역; --변수, 상수, 커서
BEGIN
    실행문;
    RETURN 변수 | 수식;
    [EXCEPTION
        예외처리문;]
END;

EX) 장바구니 테이블에서 2005년 6월 5일 판매된 상품코드를 입력 받아 상품명을 출력하는 함수를 작성하시오
1. 함수명 : FN_PNAME_OUTPUT
2. 매개변수 : 입력용 : 상품코드
3. 반환값 : 상품명
(함수생성)
CREATE OR REPLACE FUNCTION FN_PNAME_OUTPUT(
    P_CODE IN PROD.PROD_ID%TYPE)
    RETURN PROD.PROD_NAME%TYPE
IS
    V_PNAME PROD.PROD_NAME%TYPE;
BEGIN
SELECT PROD_NAME INTO V_PNAME--이름구해서 밖으로 빼내기 위해 이름을 구해서 잠시 보관용
    FROM PROD
    WHERE PROD_ID = P_CODE;

    RETURN V_PNAME;
END;
--(실행)
SELECT CART_MEMBER, FN_PNAME_OUTPUT(CART_PROD)
FROM CART
WHERE CART_NO LIKE '20050605%';
--SELECT절에 사용되어지기때문에 전체결과값이 아닌 실행될때마다 하나씩 호출 cursor를 사용안해도됨(여러결과값의 각각의 값을 하나씩 호출 )

EX) 2005년 5월 모든 상품별에 대한 매입현황을 조회하시오
Alias는 상품코드, 상품명, 매입수량, 매입금액
--일반 아우터 조인 사용 못함
--1) ansi 아우터조인 쓰거나 서브쿼리 사용해야함
OUTER JOIN

SELECT B.PROD_ID AS 상품코드,
        B.PROD_NAME AS 상품명,
        SUM(A.BUY_QTY) AS 매입수량, 
        SUM(A.BUY_QTY * B.PROD_COST) AS 매입금액
FROM BUYPROD A, PROD B --부족한 쪽에 NULL을 넣어줘서 부족한 쪽에널이 나옴 그러므로 많은쪽에 써야함 카운트 함수쓸때 *쓰면 안됨
WHERE A.BUY_PROD(+) = B.PROD_ID
    AND A.BUY_DATE BETWEEN '20050501' AND '20050531'
GROUP BY B.PROD_ID, B.PROD_NAME; --이결과 : 내부조인 WHY? AND A.BUY_DATE BETWEEN '20050501' AND '20050531' 때문 => 일반조건이 외부조인과 같이 결합되면 일반 외부조인 결과는 안나옴 (내부조인으로 바뀌어 나옴)

(ANSI OUTER JOIN)

SELECT B.PROD_ID AS 상품코드,
        B.PROD_NAME AS 상품명,
       NVL(SUM(A.BUY_QTY),0) AS 매입수량, 
        NVL(SUM(A.BUY_QTY * B.PROD_COST),0) AS 매입금액
FROM BUYPROD A
RIGHT OUTER JOIN PROD B ON  (A.BUY_PROD = B.PROD_ID--B 테이블이 더 많은 갯수의 자료를 갖고있음 
    AND A.BUY_DATE BETWEEN '20050501' AND '20050531') -- WHERE 절이 없이 사용될때는 이조건이 두테이블에만 관련되었을 때 
GROUP BY B.PROD_ID, B.PROD_NAME;

(SUBQUERY 사용경우)
SELECT BUY_PROD, 
        SUM(BUY_QTY),
        SUM(BUY_QTY * BUY_COST)
FROM BUYPROD
WHERE BUY_DATE BETWEEN '20050501' AND '20050531'
GROUP BY BUY_PROD;  --내부조인이라 판매되어진 것만 나옴

SELECT B.PROD_ID AS 상품코드 ,
       B.PROD_NAME AS 상품이름,
       NVL(A.QAMT,0) AS 구입수량,
       NVL(A.HAMT,0) AS 구입금액
FROM( SELECT BUY_PROD AS BID, 
            SUM(BUY_QTY) AS QAMT,
            SUM(BUY_QTY * BUY_COST) AS HAMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050501' AND '20050531'
        GROUP BY BUY_PROD) A, PROD B
WHERE A.BID(+) = B.PROD_ID;  --함수를 사용하면 어떤 아우터조인을 사용할지 생각안해도됨

(함수 사용) --함수나 프로시져는 결과를 한개만 리턴시켜줌 => 문자열로바꿔서 하나로만든다음 
CREATE OR REPLACE FUNCTION FN_BUYPROD_AMT(
    P_CODE IN PROD.PROD_ID%TYPE)
    RETURN VARCHAR2
IS -- IS~BEGIN 사이 : 되돌려줄 결과값을 선언하는 자리
    V_RES VARCHAR2(100); --매입수량과 매입금액을문자열로 변환하여 기억 (반환될 데이터)
    V_QTY NUMBER := 0; --매입수량
    V_AMT NUMBER := 0; --매입금액 합계
BEGIN
    SELECT SUM(BUY_QTY), SUM(BUY_QTY * BUY_COST) INTO V_QTY, V_AMT
    FROM BUYPROD
    WHERE BUY_PROD = P_CODE
    AND BUY_DATE BETWEEN '20050501' AND '20050531';
    IF V_QTY IS NULL THEN
        V_RES:= '0'; 
    ELSE
    V_RES:= '수량 : '|| V_QTY || ', ' || '구매금액 : ' || TO_CHAR(V_AMT , '99,999,999');
    END IF;
    RETURN V_RES;
END;

(실행)
SELECT PROD_ID AS 상품코드, 
        PROD_NAME AS 상품명,
        FN_BUYPROD_AMT(PROD_ID) AS 구매내역
FROM PROD;
---------------------------------------<<<<<<<<<<<<<전체판매수량, 판매금액합계 구해보기>>>>>>>>------------------------------------
상품코드를 입력받아 2005년도 상품별 평균판매횟수, 판매수량합계, 판매금액합계를 출력할 수 있는 함수를 작성하시오
1 함수명: FN_CART_QAVG, --평균판매횟수 
         FN_CART_QAMT, --전체판매수량
         FN_CART_FAMT, --판매금액합계 조인만 더들어감
2. 매개변수 : 입력 : 상품코드, 년도
CREATE OR REPLACE FUNCTION FN_CART_QAVG(
    P_CODE IN PROD.PROD_ID%TYPE,
    P_YEAR CHAR)
    RETURN NUMBER
AS
    V_QAVG NUMBER:=0;
    V_YEAR CHAR(5):=P_YEAR || '%';
BEGIN
    SELECT ROUND(AVG(CART_QTY)) INTO V_QAVG
    FROM CART
    WHERE CART_NO LIKE V_YEAR
        AND CART_PROD = P_CODE;
    
    RETURN V_QAVG;
END;
( 실행 )
SELECT PROD_ID,
       PROD_NAME,
       FN_CART_QAVG(PROD_ID, '2005')
FROM PROD;
----------------------------------------------------------------------------------------------------------------------------
문제] 2005년 2~3월 제품별 매입수량을 구하여(1) 재고수불테이블을 UPDATE하시오 UPDATE : REMAIN
처리일자는 2005년 3월 마지막일임 --> 함수이용
 2) 매개변수 : 상품코드, 매입수량
 3) 처리 내용 : 해당상품코드에 대한 입고수량, 현재고수량[], 날짜 UPDATE
(함수에서 업데이트하는 방법) 
CREATE OR REPLACE FUNCTION FN_REMAIN_UPDATE(
    P_PID IN PROD.PROD_ID%TYPE,
    P_QTY IN BUYPROD.BUY_QTY%TYPE,
    P_DATE IN DATE)
    
    RETURN VARCHAR2 --업데이트 되었다는 문자를 쓰기 위한 반환
AS
V_MESSAGE VARCHAR2(100);
BEGIN
  UPDATE REMAIN                                       --입고수량이 존재하는 것에는 + 해야함
        SET (REMAIN_I, REMAIN_J_99, REMAIN_DATE)= (SELECT REMAIN_I + P_QTY, 
                                                         REMAIN_J_99 + P_QTY,
                                                         P_DATE  
                                                         FROM REMAIN
                                                         WHERE REMAIN_YEAR = '2005' --SELECT 절에 대해 처리되어질 내용의 WHERE절
                                                            AND PROD_ID = P_PID) --이상태로 끝내면 모든 자료가 업데이트 대상이 됨 매입이 안된 자료들은 다 NULL처리됨
--REMAIN 제품수량을 가리기 위한 조건                                                       
WHERE  REMAIN_YEAR = '2005'
   AND PROD_ID = P_PID;
   V_MESSAGE:= P_PID || '제고 입고처리 완료';
 RETURN V_MESSAGE;
END;

DECLARE
    CURSOR CUR_BUYPROD
    IS
    SELECT BUY_PROD, SUM(BUY_QTY) AS AMT
FROM BUYPROD
WHERE BUY_DATE BETWEEN '20050201' AND '20050331'
 GROUP BY BUY_PROD;
V_RES VARCHAR2(100);
BEGIN
    FOR REC_BUYPROD IN CUR_BUYPROD LOOP
    V_RES := FN_REMAIN_UPDATE(REC_BUYPROD.BUY_PROD, REC_BUYPROD.AMT, LAST_DAY('20050331'));
    DBMS_OUTPUT.PUT_LINE(V_RES);
    END LOOP;
END;                                                    
                                                    
SELECT * FROM REMAIN;

<<<TRIGGER>>>
- 어떤 이벤트가 발생하면 그 이벤트의 발생 전(前), 후(後)로  자동적으로 실행되는 코드블록(프로시져의 일종)
 (사용형식)
 CREATE TRIGGER 트리거명
    (trimming)BEFORE | AFTER  (event)INSERT | UPDATE | DELETE --사기전 PROD 테이블에 등록하는 것이 TRIGGER
    ON 테이블명
    [FOR EACH ROW] 
    [WHEN 조건]
[DECLARE 
    변수,상수커서;
]
BEGIN
    명령문(들); --트리거처리문
    [EXCEPTION
     예외처리문;
     ]
END;

. 'trimming' : 트리거처리문 수행 시점 (BEFORE : 이벤트 발생전, AFTER : 이벤트 발생후)
. 'event' : 트리거가 발생될 원인 행위 (OR로 연결 사용 가능 EX) INSERT OR UPDATE OR DELETE)
. '테이블명' : 이벤트가 발생되는 테이블이름
. 'FOR EACH ROW' : 행단위 트리거 발생, 생략되면 문장단위 트리거 발생
. WHEN 조건 : 행단위 트리거에서만 사용 가능, 이벤트가 발생될 세부조건 추가 설정

-------------JAVA에서 실수로 잘못 지웠을 경우 ---------
INSERT INTO EMP
SELECT  *  
  FROM emp  AS OF TIMESTAMP(SYSTIMESTAMP-INTERVAL '1' HOUR)  
 WHERE deptno = 10;
 
 SELECT *
 FROM EMP;
SELECT *
FROM TB_JDBC_BOARD