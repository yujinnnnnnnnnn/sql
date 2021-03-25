사용용도 : 실적데이터
월별실적
              반도체       핸드폰     냉장고
2021년 1월      500         300       400
2021년 2월     null(=0)   null(=0)   null(=0)        
2021년 3월      500         300       400

outer join 을하면 
테이블 1과 테이블2 행값이 같아짐


outer join 실습 2~3
outer join 작업을 시작하세요 .buy_date 컬럼이 null인 항목이 안나오도록 
다음처럼 데이터를 채워지도록 쿼리작성 2) buy_qty를
SELECT TO_DATE('2005/01/25', 'YYYY/MM/DD'), buy_date, buy_prod, prod_id, prod_name,NVL(buy_qty, 0)
FROM buyprod , prod
WHERE buyprod.buy_prod(+) = prod.prod_id
    AND buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');

실습 4
cycle, product 테이블을 이용하여 고객이 애음하는 제품 명칭을 표현하고, 애음하지 않는 제품도 다음과 같이 조회되도록 쿼리작성
(고객은 cid=1인 고객만 나오도록 제한,null 처리) / --LEFT 를 사용할지 RIGHT 사용할지 결정해야함
--cycle은 오른쪽3개 product 2개 왼쪽(product가 변하지 않으므로 product가 마스터임)
SELECT product.*, :cid, NVL(cycle.day,0) day, NVL(cycle.cnt, 0) cnt
FROM product LEFT OUTER JOIN cycle ON (product.pid = cycle.pid AND cid =1);
 
--oracle
프롬절 나열 outer join에 대한 문법 = 데이터가 안나오는 쪽(cycle)에 (+)기호 붙여줌
SELECT product.*, :cid, NVL(cycle.day,0) day, NVL(cycle.cnt, 0) cnt
FROM product, cycle 
WHERE product.pid = cycle.pid(+) 
    AND cid(+) = :cid;
------------------------------------------------------------------
<<과제>>     
ouyter join4를 바탕으로 고객 이름 컬럼 추가하기

select *
from customer;

select *
from cycle;

SELECT product.*, :cid, NVL(cycle.day,0) day, NVL(cycle.cnt, 0) cnt, customer.cnm
FROM product, cycle, customer
WHERE product.pid = cycle.pid(+) 
    AND cycle.cid(+) = :cid
    AND :cid = customer.cid;
------------------------------------------------------------------
★ WHERE / GROUP BY(그룹핑) / JOIN

JOIN정리
문법
: ANSI / ORACLE
논리적 형태
: SELF JOIN(동일한 테이블간 조인 )/ NON-EQUI-JOIN(연결조건이 아닌것 EX.급여등급 BETWEEN AND와 같이 사용)<==> EQUI-JOIN
연결조건 성공 실패에 따라 조회여부 결정
: OUTER JOIN <==> INNER JOIN : 연결이 성공적으로 이루어진 행에 대해서만 조회가 되는 조인
SELECT*
FROM dept (INNER)JOIN emp ON(dept.deptno = emp.deptno);

CROSS JOIN
. 별도의 연결조건이 없는 조인
. 묻지마 조인
. 두 테이블의 행간 연결가능한 모든 경우의 수로 연걸
 ==> CROSS JOIN의 결과는 두테이블의 행의 수를 곱한 값과 같은 행이 반환된다.
 . 데이터 복제를 위해 사용
EX.
SELECT *
FROM emp, dept;
-- emp 행 1하나 당 dept의 행 4개
 
--ORACLE 문법
SELECT *
FROM emp CROSS JOIN dept;
 
--CROSS JOIN 실습1
customer, product 테이블을 이용하여 고객이 애음 가능한 모든 제품의 정보를 결합하여 다음과 같이 조회되도록 쿼리 작성
SELECT *
FROM customer CROSS JOIN product; 
 
--대전 중구
도시발전지수 : (KFC + 맥도날드 + 버커킹) / 롯리
SELECT *
FROM BURGERSTORE;
SELECT STORECATEGORY
FROM BURGERSTORE
WHERE SIDO ='대전';
GROUP BY STORECATEGORY;

SELECT SIDO, SIGUNGU--, 도시발전지수
FROM BURGERSTORE
WHERE SIDO ='대전'
    AND SIGUNGU = '중구';
-- 각 햄버거 브랜드를 구해주고 select 절에 
--만들기 
 
SELECT *
FROM BURGERSTORE
WHERE SIDO ='대전'
AND SIGUNGU = '중구';

SELECT SIDO, SIGUNGU, COUNT(STORECATEGORY)
FROM BURGERSTORE
WHERE SIDO ='대전'
    AND SIGUNGU = '중구'
GROUP BY SIDO, SIGUNGU, STORECATEGORY;
HAVING SUM;

------------------sem 풀이 ------------
--행을 컬럼으로 변경 (pivot)
-- decode 풀이
SELECT sido, sigungu,
   ROUND( (SUM(DECODE(storecategory, 'BURGER KING', 1, 0)) + 
   SUM(DECODE(storecategory, 'KFC', 1, 0)) +
   SUM(DECODE(storecategory, 'MACDONALD', 1, 0)) ) /
   DECODE(SUM(DECODE(storecategory, 'LOTTERIA', 1, 0)), 0, 1, SUM(DECODE(storecategory, 'LOTTERIA', 1, 0))), 2)idx
FROM burgerstore
GROUP BY sido, sigungu
ORDER BY idx DESC;
--------------------------CASE 절일때---------------------
SELECT sido, sigungu, storecategory,
CASE 
        WHEN storecategory = 'BURGER KING' THEN
        ELSE 0
    storecategory가 BURGER KING이면 1, 0,   --조건분개
    storecategory가 KFC이면 1, 0,
    storecategory가 MACDONALD이면 1, 0,
    storecategory가 LOTTERIA이면 1, 0,
FROM burgerstore;