2021_04_12 보강
1.ROLLUP
- GROUP BY 절과 같이 사용하여 추가적인 집계정보를 제공함
- 명시한 표현식의 수와 순서 (오른쪽에서 왼쪽 순)에 따라 레벨별로 짖ㅂ계한 결과를 반환함
- 표현식이 N개 사용된 경우 N+1 가지의 집계 반환
(사용형식)
SELECT 컬럼 list
FROM 테이블명
WHERE 조건
GROUP BY [컬럼명] ROLLUP(컬럼명1, 컬럼명2,..,컬럼명N)
. ROLLUP 안에 기술된 컬럼명, 컬럼명2,.., 컬럼명N을 오른쪽부터 왼쪽순으로 레벨화 시키고 그것을 기준으로 집계결과 반환

사용예) 우리나라 광역시도의 대출현황 테이블에서 기간별(년), 지역별 구분별 잔액합계를 조회하시오
(GROUP BY 절 사용)
SELECT SUBSTR(PERIOD,1,4) AS "기간(년)", REGION AS 지역, GUBUN AS 구분, SUM(LOAN_JAN_AMT) AS 잔액합계
FROM KOR_LOAN_STATUS
GROUP BY SUBSTR(PERIOD,1,4),REGION,GUBUN--일반 컬럼과 집계함수가 같이 사용되면 일반컬럼다음 그룹바이 반드시 시켜야함
ORDER BY 1;

(ROLLUP 절 사용) 
SELECT SUBSTR(PERIOD,1,4) AS "기간(년)", REGION AS 지역, GUBUN AS 구분, SUM(LOAN_JAN_AMT) AS 잔액합계
FROM KOR_LOAN_STATUS
GROUP BY ROLLUP (SUBSTR(PERIOD,1,4),REGION,GUBUN)--3개 가지고 집계를 냄 ()안에 사용된 모튼컬럼을 가지고 집계를냄
ORDER BY 1;
--레벨별로 구분을 낸다는 것은 롤업컬럼을 기준으로 오른쪽부터 제거하여 집계를 냄 마지막에는 롤업절 안에있는 모든것을 집계를 냄
--그룹바이절에는 전체집계가 안나옴
--구분집계 -> 지역집계 -> 기간집계 -> 전체 집계순

(부분롤업 )
SELECT SUBSTR(PERIOD,1,4) AS "기간(년)", REGION AS 지역, GUBUN AS 구분, SUM(LOAN_JAN_AMT) AS 잔액합계
FROM KOR_LOAN_STATUS
GROUP BY SUBSTR(PERIOD,1,4), ROLLUP(REGION,GUBUN)-- 2011 / 강원도 ,기타대출 => 기간/지역 => 기간 [롤업 밖으로 컬럼이빠지면  롤업안과 밖  이 동등]
ORDER BY 1;

REPRIOD 년도 월까지
REGION 광역시도
GUBUN 주택담보대출
LOAN_JAN_AMT지역별 월별 대출잔액합계

2. CUBE
- GROUP BY 절과 같이 사용하여 추가적인 집계정보를 제공함
- CUBE 절안에 사용된 컬럼의 조합가능한 가지수 만큼의 종류별 집계반환(2의 n승)
 (CUBE 사용) 
SELECT SUBSTR(PERIOD,1,4) AS "기간(년)", REGION AS 지역, GUBUN AS 구분, SUM(LOAN_JAN_AMT) AS 잔액합계
FROM KOR_LOAN_STATUS
GROUP BY CUBE (SUBSTR(PERIOD,1,4),REGION,GUBUN)
ORDER BY 1;  --2의 3승 = 8가지

