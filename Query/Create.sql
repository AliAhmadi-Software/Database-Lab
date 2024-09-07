CREATE TABLE "Employer"
(
  e_id INTEGER NOT NULL,
  username CHARACTER VARYING(30),
  e_password CHARACTER VARYING(30),
  mobile_phone CHARACTER VARYING(20),
  company CHARACTER VARYING(20),
  credit_card CHARACTER VARYING(30),
  email CHARACTER VARYING(30),
  is_active BOOLEAN,
  rate INTEGER,
  PRIMARY KEY (employer_id)
);


CREATE TABLE "Category"
(
	c_id INTEGER NOT NULL,
	c_name CHARACTER VARYING(20),
	PRIMARY KEY (c_id)
);


CREATE TABLE "Project"
(
	p_id INTEGER NOT NULL,
	pname CHARACTER VARYING(60),
	skills CHARACTER VARYING(200),
	pdesc CHARACTER VARYING(250),
	offer_price INTEGER NOT NULL CHECK(offered_price > 0 and offered_price<=100000000),
	created_date DATE NOT NULL,
	deadline DATE NOT NULL CHECK (expire_date > created_date),
	c_id INTEGER NOT NULL,
	is_active BOOLEAN,
	PRIMARY KEY (project_id),
	FOREIGN KEY (c_id) REFERENCES "Category" (c_id)
);


CREATE TABLE "Freelancer"
(
	f_id INTEGER NOT NULL,
	username CHARACTER VARYING(20),
	f_password CHARACTER VARYING(20),
	mobile_phone CHARACTER VARYING(20),
	email CHARACTER VARYING(30),
	skills CHARACTER VARYING(250),
	credit_card CHARACTER VARYING(30),
	f_resume CHARACTER VARYING(400),
	about CHARACTER VARYING(500),
	is_active BOOLEAN,
	rate INTEGER,
	PRIMARY KEY (f_id)
);


CREATE TABLE "Tb_create"
(
	create_id INTEGER NOT NULL,
	e_id INTEGER NOT NULL,
	p_id INTEGER NOT NULL,
	PRIMARY KEY(create_id, e_id, p_id),
	FOREIGN KEY (employer_id) REFERENCES "Employer" (e_id),
	FOREIGN KEY (project_id) REFERENCES "Project" (p_id)
);


CREATE TABLE "Tb_apply"
(
	apply_id INTEGER NOT NULL,
	p_id INTEGER NOT NULL,
	f_id INTEGER NOT NULL,
	PRIMARY KEY(apply_id, f_id, p_id),
	FOREIGN KEY (p_id) REFERENCES "Project" (p_id),
	FOREIGN KEY (f_id) REFERENCES "Freelancer" (f_id)
);


CREATE TABLE "Contact"
(
	Contact_id INTEGER NOT NULL,
	e_id INTEGER NOT NULL,
	p_id INTEGER NOT NULL,
	f_id INTEGER NOT NULL,
	created_date DATE NOT NULL,
	C_subject CHARACTER VARYING(500) NOT NULL,
	C_offer CHARACTER VARYING(50) NULL,
	C_text CHARACTER VARYING(500) NOT NULL,
	PRIMARY KEY(Contact_id),
	FOREIGN KEY (f_id) REFERENCES "Freelancer" (f_id),
	FOREIGN KEY (e_id) REFERENCES "Employer" (e_id),
	FOREIGN KEY (p_id) REFERENCES "Project" (p_id)
);


CREATE TABLE "Payment"
(
	payment_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	p_result BOOLEAN,
	PRIMARY KEY(payment_id)
);


CREATE TABLE "Contract"
(
	contract_id INTEGER NOT NULL,
	final_price INTEGER NOT NULL,
	Contract_date DATE NOT NULL,
	p_id INTEGER NOT NULL,
    e_id INTEGER NOT NULL,
	p_id INTEGER NOT NULL,
	f_id INTEGER NOT NULL,
	PRIMARY KEY(contract_id),
	FOREIGN KEY (p_id) REFERENCES "Payment" (p_id),
	FOREIGN KEY (e_id) REFERENCES "Employer" (e_id),
	FOREIGN KEY (p_id) REFERENCES "Project" (p_id),
	FOREIGN KEY (f_id) REFERENCES "Freelancer" (f_id)
);




