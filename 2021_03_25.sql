--실습5 
cycle, prodict 테이블을 이용하여 cid =1인 고객이 애음하지 않는 제품을 조회하는 쿼리작성
select pid, pnm
from product
where pid NOT IN (select pid
                    from cycle
                    where cid =1);
-------------
 ==특정직원을 알기위해 사용됨
sub6]
cycle 테이블을 이용하여 cid=1 인 고객이 애음하는 제품중 cid =2 인 고객도 애음하는 제품의 애음정보를 조회하는 쿼리
--답
select *
from cycle
where cid =1
 and pid in (select pid
              from cycle
              where cid =2);
--하드코딩방법
select *
from cycle
where cid =1
 and pid in (100, 200);
 
1. 
select *
from cycle
where cid =1

2. 2번고객이 먹는 제품에 대해서만 1번고객이 먹는 애음 정보조회
select *
from cycle
where cid =2;

sub7]
customer, cycle, product 테이블을 이용하여 cid = 1인 고객이 애음하는 제품중 cid=2인 고객도 애음하는 제품의 애음정보를 
조회하고 고객명과 제품명까지 포함하는 쿼리 작성
(조인으로 풀어야함)
--답
 select customer.cnm, product.pid, product.pnm ,cycle.day, cycle.cnt
from cycle, customer, product
where cycle.cid =1                  --크로스 조인
 and cycle.cid = customer.cid      --  cycle과 customer 조인 5* 4 
 and cycle.pid = product.pid      --cycle 과 product 조인
 and cycle.pid in (select pid
              from cycle
              where cid =2);
              
EXISTS 서브쿼리 연산자 : 단항
--연산자 : 몇항인가 생각해보기
--1+5//   ?
--++, --
[NOT] IN : WHERE 컬럼 | EXPRESSION IN (값, 값2, 값3...)
[NOT] EXISTS : WHERE EXISTS (서브쿼리)
        ==> 서브쿼리의 실행결과로 조회되는 행이 **하나라도** 있으면 TRUE, 없으면 FALSE (값이 중요 X)/ 행 존재 여부가 중요
        ==> EXISTS 연산자와 사용되는 서브쿼리는 상호연관, 비상호연관 서브쿼리 둘다 사용 가능하지만
        행을 제한하기 위해서 상호연관 서브쿼리와 사용되는 경우가 일반적이다.
        
        서브쿼리에서 EXISTS 연산자르 만족하는 행을 하나라도 발견을 하면 더이상 진행하지 않고 효율적으로 일을 끊어 버림
        서브쿼리가 1000건이라 하더라고 10번째 행에서 EXISTS 연산을 만족하는 행을 발견하면 나머지 990 건정도의 데이터는 확인 안함
--매니저가 존재하는 직원
SELECT *
FROM emp
WHERE mgr IS NOT NULL;

SELECT *
FROM emp e
WHERE EXISTS (SELECT empno -- 'X' 로사용가능
              FROM emp m
              WHERE e.mgr = m.empno);  --상호연관서브 쿼리
              
SELECT *
FROM emp e
WHERE EXISTS (select 'X'
                from dual);  -- 모두 참임 why? 서브쿼리가 비상호연산자이기 때문에
                             -- 메인 쿼리에 영향을 주지 않기 때문에 행이 있거나 없거나 둘중 하나
                             
SELECT COUNT(*) cnt
FROM emp
WHERE deptno = 10;

if( cnt > 0){
}

SELECT *
FROM dual
WEHRE EXISTS (SELECT 'X' FROM emp WHERE deptno = 10);   -- 위에 쿼리보다 더 효율적

sub9]
cycle, product 테이블을 이용하여 cid =1인 고객이 애음하는 제품을 조회하느 쿼리를 exists연산자를 이용하여 작성
1.
select *
from product;
2.
select *
from cycle
where cid = 1;
3.
select *
from product
where exists (select *
              from cycle
              where cid =1
              and product.pid = cycle.pid);
4.
select *
from product
where exists (select 'x'
              from cycle
              where cid =1
              and product.pid = cycle.pid);
--not 일때
select *
from product
where not exists (select 'X'
                from cycle
                where cid =1
                and product.pid = cycle.pid);
                
집합연산
- 행을 확장 -> 위 아래
 위아래 집합의 col의 개수와 타입이 일치해야한다
<UNION/ UNION ALL (합집합)>
UNION : {a,b} U {a,c} = {a, a, b, c} ==> {a,b,c}
수학에서 말하는 합집합
두개의 select 결과를 하나로 합친다 / 중복데이터는 중복 제거
ex.
select empno, ename
from emp
where empno IN (7369, 7499)

UNION   --컬럼의 갯수가 맞아야함 만약 두중 하나의 쿼리에서 컬럼 갯수가 맞지 않으면 에러가 뜸
        -- 만약 컬럼의 갯수가 동일하지 않을 경우 하나의 가짜컬럼(NULL)을 만들어서 UNION사용
select empno, ename
from emp
where empno IN (7369, 7521);

UNION ALL : {a,b} U {a,c} = {a, a, b, c} 
중복을 허용하는 합집합
중복을 제거하지 않음 union 연산자에 비해 속도 빠름 (중복 제거 로직이 없기 때문)
합집합 하려는 집합간 중복이 없다는 것을 알고 있을 경우 UNION 연산자보다 UNION ALL 연산자가 유리하가
EX.
select empno, ename
from emp
where empno IN (7369, 7499)

UNION ALL   
        
select empno, ename
from emp
where empno IN (7369, 7521);

INTERSECT (교집합)
두 집합의 고통된 부분
EX.
select empno, ename
from emp
where empno IN (7369, 7499)

INTERSECT 
        
select empno, ename
from emp
where empno IN (7369, 7521);

MINUS (차집합)
차집합 : 한 집합에만 속하는 데이터
        한쪽 집합에서 다른 한쪽 집합을 제외한 나머지 요소들을 반환
EX.
select empno, ename
from emp
where empno IN (7369, 7499)

MINUS
        
select empno, ename
from emp
where empno IN (7369, 7521);

교환 법칙
A U B == B U A(UNION, UNION ALL)
A^B == B^A
A-B != B-A  => 집합의 순서에 따라 결과 달라질 수 있다 [주의]

집합연산 특징
1. 집합연산의 결과로 조회되는 데이터의 컬럼 이름은 컷번째 집합의 컴럼을 따른다
select empno e, ename enm        --실행하면 e, enm 컬럼이 나옴
from emp e
where empno IN (7369, 7499)

UNION
       
select empno, ename
from emp
where empno IN (7369, 7521);
2. 집합연산의 결과를 정렬하고 싶으면 가장 마지막 집합 뒤에 ORDER BY를 기술한다
    . 개별 집합에 order by를 사용한 경우 에러
    단 order by를 적용한 인라인 뷰를 사용하는 것은 가능
EX.    
select empno e, ename enm 
from emp e
where empno IN (7369, 7499)

UNION
        
select empno, ename
from emp
where empno IN (7369, 7521)
ORDER BY e;

--인라인뷰
select e, enm
from
(select empno e, ename enm 
from emp e
where empno IN (7369, 7499)
ORDER BY e)

UNION
        
select empno, ename
from emp
where empno IN (7369, 7521)
ORDER BY e;

3. 중복된 것들은 제거 된다 (예외 union all)
[4. 9i 이전버전 그룹연산을 하게되면 기본적으로 자동 오름차순 정렬되어 나옴
    이후버전 ==> 정렬을 보장하지 않음]
    
DML 
    .SELECT
    . 데이터 신규 입력 : INSERT
    . 기존 데이터 수정 : UPDATE
    . 기존 데이터 삭제 : DELETE
    
INSERT 문법
INSERT INTO 테이블명 [({column})] values ({values})

INSERT INTO 테이블명 (컬럼명1, 컬럼명2, 컬럼명3 ...)
            VALUES (값1, 값2, 값3 ...)
            
만약 테이블에 존재하는 모든 컬럼에 데이터를 입력하는 경우 컬럼명은 생략 가능하고
값을 기술하는 순서를 테이블에 정의된 컬럼 순서와 일치시킨다.
EX.
INSERT INTO 테이블명 VALUES(값1, 값2, 값3 ...);
INSERT INTO dept VALUES(99, 'ddit', 'daejeon');

INSERT INTO dept(deptno, dname, loc)
--DESC dept; --하고   ()에 넣어줌
           VALUES(99, 'ddit', 'daejeon');

DESc emp;           
INSERT INTO emp (empno, ename, job) 
            values (9999, 'brown', 'RANGER');
            
select *
from emp;
 
 INSERT INTO emp (empno, ename, job, hiredate, sal, comm) 
            values (9998, 'sally', 'RANGER', TO_DATE('2021-03-24', 'YYYY-MM-DD'), 1000, null);   
            
여러건을 한번에 입력하기
INSERT INTO 테이블명
SELECT 쿼리  --SELECT에 조회된 데이터를 몇건이건 상관없이 입력가능

INSERT INTO dept
SELECT 90, 'DDIT', '대전'       --select 쿼리
FROM dual UNION ALL
SELECT 80, 'DDIT8', '대전' FROM dual;

select *
from dept;


UPDATE : 테이블에 존재하는 기존 데이터의 값을 변경

UPDATE 테이블명 SET 컬럼명1 = 값1, 컬럼명2 = 값2, 컬럼명3 = 값3 ...
WHERE; ★ 누락 되어있는지 확인  

SELECT *
FROM dept;

부서번호 99번 부서정보를 부서명 = 대덕IT로 , loc = 영민빌딩으로 변경

UPDATE dept SET dname = '대덕IT', loc = '영민빌딩'
--WHERE 절이 누락된 경우 테이블의 모든 행에 대해 업데이트를 진행
WHERE deptno = 99;  --부서번호 99번

--TCL
ROLLBACK;
SELECT *
FROM dept;

