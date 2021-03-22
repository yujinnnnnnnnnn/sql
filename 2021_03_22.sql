--join 실습 1
prod.exed 와 lprod테이블을 조인하여연결
컬럼 안에 있는 데이터들을 보고 주항목과 세부항목 

select lprod.lprod_gu, lprod.lprod_nm,
prod.prod_id, prod.prod_name
from lprod, prod
where lprod.lprod_gu = prod.prod_lgu;


erd다이어그램을 참고하여 buyer, prod 테이블을 조인하여
buyer별 담당하는 제품 정보를 다음과 같은 결과가 나오도록 쿼리 작성

--join 실습 2
select buyer.buyer_id, buyer_name,
    prod.prod_id, prod.prod_name
from buyer, prod
where buyer.buyer_id = prod.prod_buyer;

--join 실습 3
erd 다이어그램을 참고하여 member, cart, prod 테이블을 조인하여 회원별 장바구니에 담은 제품정보르 다음과 같은 결과가 나오는 쿼리를 작성

select mem_id, mem_name, prod.prod_id, prod.prod_name, cart_qty
from member, cart, prod
where member.mem_id = cart.cart_member
 and cart.cart_prod = prod.prod_id;
 
 from member JOIN cart ON (....)
    JOIN 다른테이블 ON

--ansi 버전
SELECT mem_id, mem_name, prod.prod_id, prod.prod_name, cart_qty
 from member JOIN cart ON ( member.mem_id = cart.cart_member)
    JOIN prod ON cart.cart_prod = prod.prod_id;

--join 실습 4    
erd 다이어그램을 참고하여 customer, cycle 테이블을 조인하여
고객별 애음 제품, 애음요일, 개수를 다음과 같은 결과가 나오도록 쿼리를
작성해보세요(고객명이 brown, sally인 고객만 조회)
(*정렬과 관계없이 값이 맞으면 정답)

select customer.cid, customer.cnm, cycle.pid, day, cnt
from customer, cycle
where customer.cid = cycle.cid
    AND customer.cnm IN ('brown','sally');

--join 실습 5
erd 다이어그램을 참고하여 customer, cycle, product 테이블을 조인하여
고객별 애음 제품, 애음요일, 개수, 제품명을 다음과 같은 결과가 나오도록
쿼리를 작성해보세요(고객명이 brown, sally인 고객만 조회)
(*정렬과 관계없이 값이 맞으면 정답)

select customer.cid, customer.cnm, cycle.pid ,product.pnm , cycle.day, cycle.cnt
from customer, cycle, product
where customer.cid = cycle.cid
    AND cycle.pid = product.pid
    AND customer.cnm IN ('brown','sally');
    
 --join 실습6   
erd 다이어그램을 참고하여 customer, cycle, product 테이블을 조인하여
애음요일과 관계없이 고객별 애음 제품별, 개수의 합과, 제품명을 다음과 같은
결과가 나오도록 쿼리를 작성해보세요
(*정렬과 관계없이 값이 맞으면 정답)

select customer.cid, customer.cnm, cycle.pid ,product.pnm , sum(cycle.cnt) cnt
from customer, cycle, product
where customer.cid = cycle.cid
    AND cycle.pid = product.pid
    AND customer.cnm IN ('brown','sally','cony')
group by customer.cid, customer.cnm, cycle.pid ,product.pnm;

--join 실습7
erd 다이어그램을 참고하여 cycle, product 테이블을 이용하여
제품별, 개수의 합과, 제품명을 다음과 같은 결과가 나오도록 쿼리를
작성해보세요
(*정렬과 관계없이 값이 맞으면 정답)

select cycle.pid ,product.pnm , sum(cycle.cnt) cnt
from  cycle, product
where  cycle.pid = product.pid
group by cycle.pid ,product.pnm;

---------outer join---------
OUTER JOIN : 컬럼 연결이 실패해도 [기준]이 되는 테이블 쪽의 컬럼 정보는 나오도록 하는 조인
LEFT OUTER JOIN : 기준이 왼쪽에 기술한 테이블이 되는 OUTER JOIN
RIGHT OUTER JOIN : 기준이 오른쪽에 기술한 테이블이되는 OUTER JOIN
FULL OUTER JOIN : LEFT OUTER + RIGHT OUTER - 중복데이터 제거

기존 사용 => 테이블 1 JOIN 테이블2
테이블1 LEFT OUTER JOIN 테이블2
테이블2 RIGHT OUTER JOIN 테이블 1 

직원의 이름, 직원의 상사 이름 두개의 컬럼이 나오도록 JOIN QUERY 작성
13 건(KING이 안나와도 괜찮음)
SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno;

--aisi
SELECT e.ename, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);

--oracle SQL OUTER JOIN 표기 :(+) 
--OUTER 조인으로 인해 데이터가 안나오는 쪽 컬럼에 (+) 붙여준다
SELECT e.ename, m.ename
FROM emp e, emp m 
WHERE e.mgr = m.empno(+);

SELECT e.ename, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno AND m.deptno = 10);
--on = 조인조건기술

SELECT e.ename, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno)
WHERE m.deptno = 10;
--e.mgr 과 m.empno 가 같고 m.deptno =10 으로 행제한

--조건이 where절에 있을 경우
SELECT e.ename, m.ename ,m.deptno
FROM emp e, emp m 
WHERE e.mgr = m.empno(+)
    AND m.deptno = 10;

--조건이 on절에 있을 경우 orcle 
SELECT e.ename, m.ename ,m.deptno
FROM emp e, emp m 
WHERE e.mgr = m.empno(+)
    AND m.deptno(+) = 10;
    
SELECT e.ename, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);

SELECT e.ename, m.ename, m.deptno
FROM emp m RIGHT OUTER JOIN emp e ON (e.mgr = m.empno);

SELECT e.ename, m.ename, m.deptno
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno);
--m.empno의 사번번호에 맞는 e.mgr 조인

--FULL OUTER : LEFT OUTER(14) + RIGHT OUTER (21) - 중복데이터 (13) = 22
SELECT e.ename, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno);

SELECT e.ename, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);

--FULL OUTER 조인은 오라클 SQL 문법으로 제공하지 않는다 오른쪽 왼쪽 중 하나만 제공/ 둘다 제공 불가능
SELECT e.ename, m.ename
FROM emp e, emp m 
WHERE e.mgr = m.empno(+);

--실습
SELECT buy_date, buy_prod, prod_id, prod_name, buy_qty
FROM buyprod RIGHT OUTER JOIN prod ON (buyprod.buy_prod = prod.prod_id
    AND buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD'));

모든 제품을 다 보여주고, 실제 구매가 있을때는 구매수량을 조회 , 없을 경우 NULL로 표현
제품코드가 : 실제 있었던 판매수량

--oracle 문법
SELECT buy_date, buy_prod, prod_id, prod_name, buy_qty
FROM buyprod , prod
WHERE buyprod.buy_prod(+) = prod.prod_id
    AND buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');