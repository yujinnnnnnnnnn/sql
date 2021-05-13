2021-04-13 보강) 조인
- 다수개의 테이블로부터 필요한 자료 추출
- rdbms 에서 가장 중요한 연산
1. 내부조인
 . 조인조건 만족하지 않은 행은 무시
 예) 상품테이블에서 상품의 분류별 상품의 수를 조회하시오
    Alias는 분류코드, 분류명, 상품의 수
**상품테이블에서 사용한 분류코드의 종류 --prod_lgu : 분류코드
select distinct prod_lgu --중복없는 분류코드 조회
from prod;



select a.lprod_gu as 분류코드, a.lprod_nm as 분류명, count(*) as "상품의 수"
from lprod a, prod b
where a.lprod_gu =  b.prod_lgu--select절을 봐야함 lprod_gu와 prod_lgu가 같은 것을 봐야함
group by a.lprod_gu, a.lprod_nm
order by 1;
--내부조인 부족한 자료
--prod_lgu 7개 / lprod 테이블 11개
--부족한 4개의 행을 null로채워서 조인 -> 외부조인

--외부조인인경우 select절에 많은 쪽을 써야함 why? 부족한 쪽을 쓰면 null나옴

ex) 2005년 5월 매출자료와 거래처테이블을 이용하여 거래처별 상품매출정보를 조회하시오 --거래처(buyer) : 매입 / 회원 : 매출 
Alias 는 거래쳐코드, 거래처명, 매출액 --얼마만큼 팔았나 => 장바구니 테이블 (매출정보가 들어있음)
select 
from cart
select 
from

select b.prod_buyer as 거래처코드, c.buyer_name as 거래처명, sum(b.prod_price * a.cart_qty)매출액
from cart a, prod b, buyer c
where a.cart_prod = b.prod_id --prod_price를 갖고오기 위한것
    and b.prod_buyer = c.buyer_id --거래처명 갖고오기위해 조인
    and a.cart_no like '200505%'--매출정보중 날짜 관련은 cart테이블 뿐
group by b.prod_buyer, c.buyer_name
order by 1;

(ansi 내부조인 형식)
select  컬럼list
from 테이블명1(하나만)
inner join 테이블명2 on (조인조건 
[and 일반조건])--두테이블의 조건이  
inner join 테이블명3 on (조인조건 
[and 일반조건])--위 두테이블 조인된 결과와 조인됨 (테이블과 조인 x) / where로 써도 무관
          :
where 조건;

(ansi)
select b.prod_buyer as 거래처코드, c.buyer_name as 거래처명, sum(b.prod_price * a.cart_qty)매출액
from cart a
inner join prod b on (a.cart_prod = b.prod_id  --조인시킬 공통컬럼인 prod가 반드시있어야됨
    and a.cart_no like'200505%')
inner join buyer c on(b.prod_buyer = c.buyer_id )
group by b.prod_buyer, c.buyer_name
order by 1;

문제 1] 2005년 1~3월 거래처별 매입정보를 조회하시오 -- 매입정보 :buyprod
    Alias 는 거래처코드, 거래처명, 매입금액합계이고 매입금액 합계가 500만원 이상인 거래처만 검색하시오. -- prod거쳐서 거래처 알아야함

select 거래처코드, 거래처명, 매입금액합
from (select b.prod_buyer as 거래처코드, c.buyer_name as 거래처명, sum(a.buy_cost * b.prod_price) as 매입금액합 
        from buyprod a, prod b, buyer c
        where a.buy_prod = b.prod_id
        and b.prod_buyer = c.buyer_id
        group by b.prod_buyer, c.buyer_name)
where 매입금액합 >= 5000000;

select b.prod_buyer as 거래처코드, c.buyer_name as 거래처명, sum(buy_cost * buy_qty) as 매입금액합 
        from buyprod a, prod b, buyer c
        where a.buy_prod = b.prod_id
        and b.prod_buyer = c.buyer_id
        and a.buy_date between '20050101' and '20050331' --날짜나 숫자는 like쓰지마셈
    group by a.buyer_id, c.buyer_name
    having sum(buy_cost * buy_qty) >= 5000000;
--여기서 그룹바이 해도 오류 집계함수는 일반조건으로 사용 못함 => 그룹바이 다음으로 써야함

문제 2] 사원테이블(employees)에서 부서별 평균급여보다 급여를 많이 받는 직원들의 수를 부서별로 조회하시오 --sub쿼리사용해
    Alias는 부서코드, 부서명, 부서평균급여, 인원수        --1) 부서별 평균급여 계산 / 2) 자신이 속한 부서의 평균 급여
                                                      --부서번호, 급여 avg()
                                                      
메인쿼리 : 사원테이블에서 부서별 부서코드, 부서명, 부서평균급여, 인원수 출력 
----------------------------------------------------------------------------------------------------------
select tbla.department_id as 부서코드, tbla.department_name as 부서명, 
        (select round(avg(salary))
            from employees tblc
            where tblc.department_id = tblb.did) as 부서평균급여, tblb.cnt as 인원수 --부서평균급여, 인원수 맞지않아서 따로 구해야함 메인쿼리에서 그룹바이 하면 안됨
from departments tbla,
        (select a.department_id as did, count(*) as cnt
            from (select department_id ,round(avg(salary)) as asal
                    from employees
                    group by department_id) a, employees b
            where a.department_id = b.department_id
                and b.salary >= a.asal  
            group by a.department_id
            order by 1) tblb
where tbla.department_id = tblb.did;
-----------------------------------------------------------------------------------

(서브쿼리: 부서별 평균급여)
(select department_id , round(avg(salary)) as asal
from employees
 group by department_id)                                                     
 
(평균급여보다 많이 받고 있는 사람 수)
select a.department_id, count(*) as cnt
from (select department_id ,round(avg(salary)) as asal
        from employees
        group by department_id) a, employees b
where a.department_id = b.department_id
    and b.salary >= a.asal  
group by a.department_id
order by 1;
    
--인원수 : 해당                                                      
select a.department_id 부서코드, c.department_name as 부서명, 부서평균급여, count(*) as 인원수
from employees a, jobs b, departments c
where a.job_id = b.job_id
    and a.department_id = c.department_id
    and salary > (select department_id as 부서코드, round(avg(salary),2) as 부서평균급여
                  from employees 
                  group by department_id) --부서별 평균급여 
group by 

select a.department_id 부서코드, c.department_name as 부서명, 부서평균급여, count(*) as 인원수
from employees a, departments c
where a.department_id = c.department_id
      and a. salary > (select department_id as 부서코드, round(avg(salary),2) as 부서평균급여
                  from employees e
                  where e.department_id = a.department_id
                  group by department_id) 

직원이 속한 부서의 급여 평균보다 높은 급여를 받는 직원을 조회
SELECT empno, ename, sal, deptno
FROM emp e
WHERE e.sal > (SELECT AVG(sal)
             FROM emp a
             WHERE a.deptno = e.deptno);
          
             
select  a.부서코드, b.department_name as 부서명, a.부서평균급여
from (select department_id as 부서코드, round(avg(salary),2) as 부서평균급여
       from employees 
       group by department_id)a, departments c
where a.department_id = c.department_id
    and a.salary > a.부서평균급여
--부서평균급여 (jobs_id)
select *
from TB_JDBC_BOARD

SELECT A.BOARD_NO, A.TITLE, A.CONTENT, B.USER_NAME, A.REG_DATE 
FROM TB_JDBC_BOARD A LEFT OUTER JOIN TB_JDBC_USER B 
ON A.USER_ID = B.USER_ID 
ORDER BY A.BOARD_NO DESC


insert into TB_JDBC_BOARD values(2,'hi', 'hello','dbwls', sysdate);
commit;