--UDF
--1 یافتن پروژه هایی که مبلغ پیشنهاد شده برای آن ها از مبلغی که کاربر وارد میکند بیشتر باشد
CREATE OR REPLACE FUNCTION check_price(price integer) 
	RETURNS TABLE (pname character VARying, pdesc  character VARying ) 
AS $$
BEGIN
RETURN QUERY SELECT p.pname, p.pdesc FROM "Project" p WHERE  offer_price > price;
END;
$$ 
LANGUAGE 'plpgsql';

select * from check_price(12000000); 


--2 تغییر دادن دسته بندی پروژه
CREATE OR REPLACE FUNCTION upd_category(id_p integer,new_cat integer) RETURNS void 
AS $$
BEGIN
update "Project" set c_id = new_cat where p_id = id_p;
END; $$ 
LANGUAGE 'plpgsql';

select upd_category(1,2)   


--3 فعال/غیر فعال کردن فریلنسر ها
CREATE OR REPLACE FUNCTION active_free(user_name char,status bool) RETURNS void 
AS $$
DECLARE
   active bool := (SELECT is_active FROM "Freelancer" WHERE username=user_name);
BEGIN
IF active!=status THEN
	update "Freelancer" set is_active=status where username=user_name;
ELSE
     RAISE NOTICE 'commend have been apllied before !';
END IF;
END; $$ 
LANGUAGE 'plpgsql';

select active_free('alihosseini',true)  


--SP
--4 غیر فعال کردن پروژه های ایجاد شده توسط یک کارفرمای خاص
CREATE OR REPLACE PROCEDURE ChangeStatus(employer_id integer)
LANGUAGE plpgsql    
AS 
$$
BEGIN
	update "Project" set is_active=FALSE where p_id=(SELECT p.p_id FROM "Project" p, "Tb_create" c
														   		WHERE employer_id=c.e_id AND c.p_id=p._id);

    COMMIT;
END;
$$;

CALL ChangeStatus(2);


--5 آپدیت مبلغ نهایی قرارداد
CREATE OR REPLACE PROCEDURE UpdateAmount(c_ic int, new_price int)
LANGUAGE plpgsql    
AS 
$$
BEGIN
     UPDATE "Contract"  SET final_price = new_price WHERE contract_id = c_ic;

    COMMIT;
END;
$$;

CALL UpdateAmount(2,10500000);


--TRIGGER
--6 هنگام حذف یک دسته بندی، پروژه های موجود در ان دسته بندی نیز حذف شوند
CREATE TRIGGER delete_project 
BEFORE DELETE ON "Category" 
FOR EACH ROW 
EXECUTE PROCEDURE delete_prj_fun(); 

CREATE OR REPLACE FUNCTION delete_prj_fun()
RETURNS trigger AS $$ 
BEGIN 
	DELETE FROM "Project" WHERE c_id=OLD.c_id;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql; 

delete  from "Category" where c_id=7


--7 وضعیت همه فریلنسر ها رو به صورت پیش فرض به صورت فعال قرار بده
CREATE OR REPLACE FUNCTION change_mode() RETURNS TRIGGER AS $$
BEGIN
	
	UPDATE "Freelancer" f SET is_active=TRUE 
	WHERE f.f_id = NEW.f_id;
	
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER  switch_mode
	AFTER INSERT ON "Freelancer"
FOR EACH ROW
EXECUTE PROCEDURE change_mode(); 


--8 از بین بردن فاصله های اضافی در یوزرنیم فریلنسر
CREATE TRIGGER  Remv_space
	BEFORE INSERT ON "Freelancer"
FOR EACH ROW
EXECUTE PROCEDURE Remove_space();

CREATE OR REPLACE FUNCTION Remove_space() RETURNS TRIGGER AS $$
BEGIN
	NEW.username = TRIM(NEW.username);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--9
CREATE TRIGGER ins_pay 
AFTER UPDATE  ON "Payment"
FOR EACH ROW 
EXECUTE PROCEDURE insert_pay();


CREATE OR REPLACE FUNCTION insert_pay() RETURNS TRIGGER AS 
$$
   BEGIN
      update "Contract" set payment_id = new.payment_id;
      RETURN NEW;
   END;
$$
LANGUAGE plpgsql;

update "Payment" set amount = amount + 300000, p_result = true  where payment_id = 1; 


--10  اعتبارسنجی شماره تلفن
CREATE OR REPLACE FUNCTION phone_update_statename() 
RETURNS trigger AS $$ 
BEGIN 
    IF length(new.mobile_phone) > 11 
    THEN RAISE EXCEPTION 'phone number is invalid !!'; 
	RETURN NULL;
    END IF; 	
    RETURN new; 
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER phone_statename 
BEFORE INSERT OR UPDATE 
ON "Employer" 
FOR EACH ROW 
EXECUTE PROCEDURE phone_update_statename(); 


--CURSOR
--11 مجموع قیمت پروژه هایی که بالای 11میلیون هستند و فریلنسر 3 برای ان ها درخواست داده است
CREATE OR REPLACE FUNCTION SumOfPrice() 
    RETURNS int AS $$ 
	DECLARE pname character varying(60);
	DECLARE p_id INT;
	DECLARE offer_price INT;
	DECLARE sum INT;
	DECLARE c CURSOR FOR (SELECT "Project".p_id, "Project".pname, "Project".offer_price
							FROM "Project" NATURAL JOIN "Tb_apply" 
								WHERE f_id = 3);
BEGIN
	OPEN c;
	sum := 0;
	LOOP
		FETCH c INTO p_id , pname, offer_price;
 		IF NOT FOUND THEN EXIT; END IF;
		IF offer_price > 11000000 THEN
	      RAISE NOTICE ' id and  prject name : %', p_id ||'-'|| pname;
 	       sum := sum + offer_price;
 		END IF;
	END LOOP;
	CLOSE c;
	RETURN sum;
 END;
$$ LANGUAGE plpgsql;

SELECT SumOfPrice();


--12 تعداد و اطلاعات کارفرمایانی که شماره همراه ان ها با 0911 شروع میشود
CREATE OR REPLACE FUNCTION EmpPrjStatus( ) 
	RETURNS int AS $$ 
	DECLARE company character varying(60);
	DECLARE mobile_phone character varying(20);
	DECLARE num INTEGER;
	DECLARE c CURSOR FOR (SELECT e.company, e.mobile_phone FROM "Employer" e WHERE e.mobile_phone LIKE '0911%');

BEGIN
	OPEN c;
	num := 0;
	LOOP
		FETCH c INTO company, mobile_phone;
		IF NOT FOUND THEN EXIT; END IF;
	      RAISE NOTICE 'company name and  status : %', company ||'-'|| mobile_phone;
		  num:=num+1;
	END LOOP;
	CLOSE c;
    RETURN num;
END;
$$ LANGUAGE plpgsql;


SELECT EmpPrjStatus();


--TRANSACTION
--13 از مبلغ قرار داد 1 به قرارداد 2 به اندازه 2میلیون انتقال یابد
BEGIN TRANSACTION;
	update "Contract" set final_price=final_price-2000000 where contract_id=1;
	update "Contract" set final_price=final_price+2000000 where contract_id=2;
COMMIT;

select * from "Contract"


--14
BEGIN TRANSACTION;
		update "Project" set offer_price = offer_price + 500000 where p_id = 4;
		update "Project" set offer_price = offer_price + 500000 where p_id = 5;
COMMIT;

select * from "Project"


--VIEW
--15 نمایش کارفرمایان فعال
CREATE VIEW Emp_Crt AS
SELECT * FROM ("Employer" NATURAL JOIN "Tb_create") WHERE is_active=TRUE;

SELECT * FROM Emp_Crt;


--16 اطلاعات پروژه هایی که فریلنسر های فعال در سایت برای آن ها در خواست ثبت کردند
CREATE VIEW Free_apply AS
SELECT pname, description, offer_price FROM "Project"
WHERE p_id IN(SELECT p_id FROM "Tb_apply" 
						WHERE f_id IN(SELECT f_id FROM "Freelancer" 
					   								WHERE is_active=TRUE));

SELECT * FROM Free_apply;



