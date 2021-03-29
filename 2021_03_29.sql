인덱스의 정렬
select ename, job, rowid
from emp
order by ename, job;
--
job, ename 컬럼으로 구성된 IDX_03 인덱스 삭제

create 객체타입 (INDEX, TABLE, SEQUN) 객체명(테이블명...);
drop 객체타입 객체명;

DROP INDEX idx_emp_03;

create index idx_emp_04 on emp (ename, job);

EXPLAIN PLAN FOR
select *
from emp
where job = 'MANAGER'
 AND ename like 'C%';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
--구성된 컬럼의 순서가 다르니 인덱스의 정렬이 달라져서 실행결과의 위치도 달라짐 (컬럼 순서 중요성)

SELECT ROWID, dept.*
FROM dept;

create index idx_dept_01 on dept(deptno);

emp
 1. table full access
 2. inx_emp_01
 3. inx_emp_02
 4. inx_emp_04
 
 dept
 1. table full access
 2. inx_dept_01
 
 emp(4) => dept(2) :8
 dept(2) => emp(4) :8
 => 16가지
 접근방법 * 테이블^개수

EXPLAIN PLAN FOR 
select ename, dname, loc
from emp, dept  
where emp.deptno = dept.deptno
    and emp.empno = 7788;
 --dept는 상수조건이 없고 emp는 상수조건이 있음 따라서 empno를 사용해서 인덱스
 
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
 --4-3-5-2-6-1-0


select dname, loc
from dept
where dept.deptno = 20;
 
 응답성 : OLPT(Online Transaction Processing) --우리가 사용하는것
 퍼포먼스 : OLAP(Online Analysis Processing)
            -은행이자 계산
--응답성이 중요하기 때문에 근접한 결과를 나타냄(정확하지 않음)   

인덱스의 단점
1. 저장공간

INDEX ACCESS
 . 소수의 데이터를 조회할 때 유리(응답속도 필요할 때)
 .Index 를 사용하는 Input/Output Single Block I/O (하나의 블럭)
 . 다량의 데이터를 인덱스로 접근할 경우 속도가 느리다(2~3000건 이상일 경우)

 <<DDL ( 테이블에 인덱스가 많다면)>>

1. 테이블의 빈공간을 찾아 데이터를 입력한다
2. 인덱스의 구성 컬럼을 기준으로 정렬된 위치를 찾아 인덱스 저장
3. 인덱스는 B*트리 구조이고, root node 부터 leaf node 까지의 depth가 항상 같도록 밸런스를 유지한다
즉 데이터 입력으로 밸런스가 무너질경우 밸런스를 맞추는 추가 작업이 필요
4. 2-4까지의 과정을 각 인덱스 별로 반복한다

 . 인덱스가 많아 질 경우 위 과정이 인덱스 개수 만큼 반복 되기 때문에 ****UPDATE, INSERT, DELETE 시 부하가 커진다****
 . 인덱스는 SELECT 실행시 조회 성능개선에 유리하지만 데이터 변경시 부하가 생긴다
 . ****테이블에 과도한 수의 인덱스를 생성하는 것은 바람직 하지 않음****
        =>어떤 쿼리가 있는지 전체 조회하고 쿼리에 맞는 인덱스를 유지하는 것이 바람직함
 . 하나의 쿼리를 위한 인덱스 설계는 쉬움
 . 시스템에서 실행되는 모든 쿼리를 분석하여 적절한 개수의 최적의 인덱스를 설계하는 것이 힘듬

TABLE ACCESS
 . 정렬에 대한 기준이 없음 (데이터가 어디에 있는지 모름)
 . 테이블의 모든 데이터를 읽고서 처리를 해야하는 경우 인덕스를 통해 모든 데이터를 테이블로 접근하는 경우보다 빠름
  .I/O 기준이 mulit block (데이터를 읽을 때 속도가  빠름)
  
 ddl (상담 일자 인덱스 (주문인덱스)) = 트리가 한쪽으로 치우지게 되면 밸런스를 맞춤
 
 --실습 idx2
 
 
 --실습 idx3
 시스템에서 사용하는 
 
 --달력 만들기 쿼리
 -- <배우고자 하는것>
  --데이터의 행을 열로 바꾸는 방법
  --레포트 쿼리에서 활용 할 수 있는 예제 연습
  
  주어진상황 = 년월 6자리 문자열 ex. '202103'
  만들것 : 해당 년월에 해당하는 달력 (7칸 짜리 테이블)
  
  '202103' ==> 31
  필요한것 : 20210301을 날짜 ... 20210331
  --(level은 1부터 시작)
  /*
select 
from dual
connect by level <(level 1~...)
  */
  
-- 일요일이면 dt 아니면 null, 월요일이면 dt 아니면 null DECODE(d, 1, dt) sun, DECODE(d, 2, dt) mon, 
 --화요일이면 dt 아니면 null, 수요일이면 dt 아니면 null 
 --목요일이면 dt 아니면 null, 금요일이면 dt 아니면 null 
 --토요일이면 dt 아니면 null
 --MAX와 MIN함수값이 동일 할 경우 MIN 권장
 
 select DECODE(d, 1,iw+1,iw), 
     MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon,
     MIN(DECODE(d, 3, dt)) tue, MIN(DECODE(d, 4, dt)) wen,
    MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
    MIN(DECODE(d, 7, dt)) sat
 from
  (select TO_DATE(:yyyymm,'yyyymm') + (level-1) dt, --날짜값
        TO_CHAR(TO_DATE(:yyyymm,'yyyymm') + (level-1),'D') d ,
        TO_CHAR(TO_DATE(:yyyymm,'yyyymm') + (level-1), 'IW') iw
  from dual
  connect by level <=TO_CHAR(LAST_DAY(TO_DATE(:yyyymm,'yyyymm')),'dd'))
  group by DECODE(d, 1, iw+1, iw)
  order by DECODE(d, 1, iw+1, iw);
  --일요일에 대한 주차 표준이 맞지 않음
  -- => 일요일일때 주차 +1
  -- iw로 group by 하면 12월 30,31 값이 알맞지 않음 다른 방법 생각해보기
  주차 : iw
  주간요일 : d 
  
--일자에 해당하는 값  
select TO_CHAR(LAST_DAY(TO_DATE(:yyyymm,'yyyymm')),'dd')
  FROM dual;

계층쿼리 - 조직도, I BOM(Bill Of Material), 게시판(답변형 게시판)
        -데이터의 상하 관계를 나타내는 쿼리
SELECT empno, ename, mgr
FROM emp;

사용방법: 1. 시작위치를 설정
         2. 행과 행의 연결 조건 기술
PRIOR --이미 읽은 데이터 , 이전의, 사전의 / CONNECT BY뒤에 자주 사용
CONNECT BY (내가 읽은 사번과 = 앞으로 읽을 행의 MGR 컬럼); 

--전체직원 
select empno, ename, mgr
from emp
START WITH empno = 7839 -- 1.시작위치 설정
--START WITH mgr IS NULL;
CONNECT BY PRIOR empno = mgr; --2. 행과 행의연결 조건을 기술


--특정 사번
SELECT empno, ename, mgr
FROM emp
START WITH empno = 7566
CONNECT BY PRIOR empno = mgr;

--level은 계층쿼리에서만 쓸 수 있는 특정 컬럼
SELECT empno, ename, mgr, level
FROM emp
START WITH empno = 7566
CONNECT BY PRIOR empno = mgr;

--level에 따라 들여쓰기 (LPAD사용하기)
SELECT empno, LPAD(' ', (LEVEL-1)*4)|| ename, mgr, level
FROM emp
START WITH empno = 7839
CONNECT BY PRIOR empno = mgr;

SELECT LPAD('TEST', 1*10) 
FROM dual;

이미 읽은데이터     앞으로 읽어야할 데이터
KING의 사번 = mgr 컬럼의 값이 king의 사번인 녀석
empno =mgr

계층쿼리 방향에 따른 분류
상향식 : 최하위 노드(leaf node)에서 자신의 부모를 방문하는 형태
하향식 : 최상위(root node) 노드에서 모든 자식 노드를 방문하는 형태

상향식 쿼리
SMITH(7369)부터 시작하여 노드의 부모를 따라가는 계층형 쿼리작성
SELECT empno, LPAD(' ', (LEVEL -1)*4)||ename, mgr, level
FROM emp
START WITH empno = 7369
CONNECT BY PRIOR mgr = empno;
--CONNECT BY smith 의 mgr 컬럼값 = 앞으로 읽을 행의 empno
SMITH - FORD

--실습 h1
최상위 노드부터 리프노드까지 탐색하는 계층쿼리 장성
LPAD를 이용항 시각적 표헌까지 포함
SELECT LPAD(' ',(LEVEL -1)*3) || deptnm deptnm
FROM dept_h  --(,부서이름,해당부서의 상위부서)
START WITH p_deptcd IS NULL
CONNECT BY PRIOR deptcd = p_deptcd; 

//가상코드
CONNECT BY PRIOR 현재행(prior)의 deptcd = 앞으로 읽을 행(그냥 기술)의 p_deptcd

--실습 h2
정보시스템부 하위의 부서계층 구조를 조회하는 쿼리 작성
SELECT deptcd, LPAD(' ',(LEVEL -1)*3) || deptnm deptnm, p_deptcd
FROM dept_h  
START WITH deptcd = 'dept0_02'
CONNECT BY PRIOR deptcd = p_deptcd;

<<oracle 계층쿼리 탐색 순서 : pre-order>>

--실습 h3
디자인 팀에서 시작하는 상향식 계층 쿼리
SELECT deptcd, LPAD(' ',(LEVEL -1)*3) || deptnm deptnm, p_deptcd
FROM dept_h  
START WITH deptcd = 'dept0_00_0'
CONNECT BY PRIOR p_deptcd = deptcd; --start with과 앞컬럼 이름이 같으면 하향식, = 뒤에 있으면 상향식
CONNECT BY PRIOR 현재행의 부모(p_deptcd) = 앞으로의 읽을 행의 부서코드deptcd;

--실습 h4
계층형 쿼리 복습.sql 을 이용하여 테이블을 생성하고 다음고 같은 결과가 나오도록 쿼리 작성
s_id : 노드 아이디
ps_id : 부모 노드 아이디
value : 노드 값
하향식임

desc h_sum;

select LPAD(' ',(LEVEL -1)*4) || s_id s_id, value
from h_sum
START WITH s_id = '0' --문자 = 숫자 (형변환이 됨) 문제발생가능이 있기때문에 문자열('')로 해야함
CONNECT BY PRIOR s_id = ps_id; 

