

DROP VIEW qprimajorinstructorview;
DROP VIEW primajorinstructorview;
DROP VIEW vw_majorstudents;

CREATE VIEW vw_majorstudents AS
	SELECT students.studentid, students.studentname, students.accountnumber, students.Nationality, students.Sex,
		students.MaritalStatus, students.birthdate, students.onprobation, students.offcampus,
		studentdegrees.studentdegreeid, studentdegrees.completed, studentdegrees.started, studentdegrees.graduated,
		departments.departmentid, departments.departmentname, majors.majorid, majors.majorname
	FROM students INNER JOIN studentdegrees ON students.studentid = studentdegrees.studentid
		INNER JOIN departments ON students.departmentid = departments.departmentid
		INNER JOIN studentmajors ON studentdegrees.studentdegreeid = studentmajors.studentdegreeid
		INNER JOIN majors ON studentmajors.majorid = majors.majorid
	WHERE (studentdegrees.completed = false)
		AND (studentmajors.major = true) AND (studentmajors.primarymajor = true); 

CREATE VIEW primajorinstructorview AS
	SELECT instructors.instructorid, instructors.instructorname, vw_majorstudents.studentid, vw_majorstudents.studentname,
		vw_majorstudents.accountnumber, vw_majorstudents.Nationality, vw_majorstudents.Sex, vw_majorstudents.MaritalStatus,
		vw_majorstudents.birthdate, vw_majorstudents.onprobation, vw_majorstudents.offcampus,
		vw_majorstudents.studentdegreeid, vw_majorstudents.completed, vw_majorstudents.started, vw_majorstudents.graduated,
		vw_majorstudents.departmentid, vw_majorstudents.departmentname, vw_majorstudents.majorid, vw_majorstudents.majorname
	FROM instructors INNER JOIN vw_majorstudents ON instructors.departmentid = vw_majorstudents.departmentid
	WHERE (instructors.majoradvisor = true);

CREATE VIEW qprimajorinstructorview AS
	SELECT primajorinstructorview.instructorid, primajorinstructorview.instructorname, primajorinstructorview.studentid, primajorinstructorview.studentname,
		primajorinstructorview.accountnumber, primajorinstructorview.Nationality, primajorinstructorview.Sex, primajorinstructorview.MaritalStatus,
		primajorinstructorview.birthdate, primajorinstructorview.onprobation, primajorinstructorview.offcampus,
		primajorinstructorview.studentdegreeid, primajorinstructorview.completed, primajorinstructorview.started, primajorinstructorview.graduated,
		primajorinstructorview.departmentid, primajorinstructorview.departmentname, primajorinstructorview.majorid, primajorinstructorview.majorname,
		qstudents.qstudentid, qstudents.quarterid, qstudents.majorapproval, qstudents.departapproval, qstudents.noapproval,	
		qstudents.org_id
	FROM primajorinstructorview INNER JOIN (qstudents INNER JOIN quarters ON qstudents.quarterid = quarters.quarterid)
		ON primajorinstructorview.studentdegreeid = qstudents.studentdegreeid 
	WHERE (quarters.active = true) AND (qstudents.finalised = true) AND (qstudents.majorapproval = false);
	
	