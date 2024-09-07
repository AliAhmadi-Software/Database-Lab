--1 نام و مبلغ پیشتهادی پروژه ها
SELECT pname, offer_price FROM "Project" ORDER BY offer_price DESC;

--2 اطلاعات پروژه هایی که فریلنسر های فعال در سایت برای آن ها در خواست ثبت کردند
SELECT pname, pdesc, offer_price FROM "Project"
WHERE p_id IN(SELECT p_id FROM "Tb_apply" 
						WHERE f_id IN(SELECT f_id FROM "Freelancer" 
					   								WHERE is_active=TRUE));

--3 اطلاعات کارفرماهایی که در پروژه هایی که ثبت کردند مهارت های ری اکت و ویو را مد نظر دارند
SELECT E.employer_id, company FROM "Employer" E, "Tb_create" tc, "Project" Pr 
	WHERE E.e_id=tc.e_id AND tc.p_id=Pr.p_id AND skills LIKE '%react%'
UNION
SELECT E.e_id, company_name FROM "Employer" E, "Tb_create" tc, "Project" Pr 
	WHERE E.e_id=tc.e_id AND tc.p_id=Pr.p_id AND skills LIKE '%vue%';

--4 اطلاعات قراردادهایی که کافرمای آن فعال است و نیاز به زبان ویو دارد
SELECT contract_id, final_price FROM "Contract" ct, "Employer" E, "Project" Pr 
	WHERE ct.p_id=Pr.p_id AND Pr.skills LIKE '%vue%' GROUP BY contract_id
INTERSECT
SELECT contract_id, final_price FROM "Contract" ct, "Employer" E, "Project" Pr 
	WHERE ct.e_id=E.e_id AND E.is_active=TRUE GROUP BY contract_id

--5 اطلاعات کارفرما هایی که قصد استفاده از زبان ری اکت در پروژه خود را ندارند
SELECT employer_id, company FROM "Employer" 
EXCEPT
SELECT E.e_id, company FROM "Employer" E, "Tb_create" tc, "Project" Pr 
	WHERE E.e_id=tc.e_id AND tc.p_id=Pr.p_id AND skills LIKE '%react%';

--6 اطلاعات قراردادهایی که نتیجه تراکنش موفقی داشته است
SELECT contract_id, final_price, date FROM "Contract"
EXCEPT
SELECT contract_id, final_price, date FROM "Contract" ct, "Payment" py
	WHERE ct.payment_id=py.payment_id AND p_result=TRUE

--7 اطلاعات کافرماهایی که قیمت پیشنهادی حداقل یک پروژه ان ها بیشتر از 12میلیون است
SELECT * FROM "Employer" E, "Tb_create" tc, "Project" Pr 
	WHERE E.e_id=tc.e_id AND tc.p_id=Pr.p_id 
		AND offer_price > ANY( SELECT offer_price FROM "Project"
							   		WHERE offer_price > 12000000);
									
--8 اطلاعات کافرماهایی که قیمت پیشنهادی ان ها از همه پروژه های تا سقف 13 تومان، بیشتر است
SELECT * FROM "Employer" E, "Tb_create" tc, "Project" Pr 
	WHERE E.employer_id=tc.employer_id AND tc.p_id=Pr.p_id 
		AND offer_price > ALL( SELECT offer_price FROM "Project"
							   		WHERE offer_price < 13000000 );

--9 یوزرنیم فریلنسرهایی که برای پروژه 3 درخواست دادند
SELECT username FROM "Freelancer" f WHERE
	EXISTS (SELECT ta.f_id FROM "Tb_apply" ta 
					WHERE ta.p_id=3 AND f.f_id=ta.f_id);

--10 تعداد پروژه هایی که بعد از تاریخ 2011-02-24 ثبت شدند
SELECT COUNT(*) FROM "Project" WHERE created_date > '2011-02-24';

--11 میانگین قیمت پروژه های توافق شده
SELECT AVG(final_price) FROM "Contract";

--12 بالاترین قیمت پیشنهادی برای کدام پروژه است
SELECT * FROM "Project" WHERE offer_price = (SELECT MAX(offer_price) FROM "Project")

--13 اولین تاریخی که هر قرارداد ثبت شد
SELECT contract_id, final_price, MIN(date) FROM "Contract"  GROUP BY contract_id;

--14 تعداد درخواست هایی که هر فریلنسر برای گرفتن پروژه داده است
SELECT COUNT(*),username 
FROM "Freelancer"  NATURAL JOIN "Tb_apply"  
GROUP BY f_id;

--15 تعداد درخواست هایی که هر فریلنسر برای گرفتن پروژه داده است
SELECT COUNT(project_id) AS PR,username 
FROM "Freelancer" LEFT OUTER JOIN "Tb_apply" 
ON "Freelancer".f_id = "Tb_apply".f_id 
GROUP BY "Freelancer".f_id
ORDER BY PR

--16 حذف پروژه هایی که در دسته بندی با ایدی 3 قرار دارند
DELETE FROM "Project" WHERE c_id=3;

--17 حذف پیام هایی که شامل کلمه سئو هستند
DELETE FROM "Contact" WHERE C_text LIKE '%سئو%';

--18
update "Employer" 
set pass='hTJFJdrytAqe'
where e_id=7;

--19
update "Payment" 
set p_result=False
where Payment_id=3;

--20
update "Project" 
set is_active=False
where project_id=7;

--21
CREATE INDEX CO_Name ON "Employer" (company);

--22
CREATE INDEX Free_username ON "Freelancer" (username);







