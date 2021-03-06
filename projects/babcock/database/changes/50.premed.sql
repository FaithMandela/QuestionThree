

SELECT sublevelid, sublevelname, org_id FROM sublevels ORDER BY sublevelid;

SELECT sublevelid, sublevelname, org_id 
FROM sublevels  WHERE (sublevelname ilike '%pre%');

SELECT qstudentid, studentdegreeid, studentid, org_id FROM qstudentview WHERE sublevelid = 'UGPM' AND quarterid = '2017/2018.1'
ORDER BY studentdegreeid;

SELECT qstudentid, studentdegreeid, studentid, org_id FROM qstudentview WHERE sublevelid = 'UGPM' AND quarterid = '2017/2018.1M'
ORDER BY studentdegreeid;

SELECT aa.qstudentid, aa.studentdegreeid, aa.org_id, ab.qstudentid, ab.studentdegreeid, ab.org_id
FROM
(SELECT qstudentid, studentdegreeid, org_id FROM qstudents
WHERE quarterid = '2017/2018.1' AND sublevelid = 'UGPM') as aa
INNER JOIN
(SELECT qstudentid, studentdegreeid, org_id FROM qstudents
WHERE quarterid = '2017/2018.1M' AND sublevelid = 'UGPM') as ab
ON aa.studentdegreeid = ab.studentdegreeid

ORDER BY aa.studentdegreeid;

SELECT qstudentview.qstudentid, qstudentview.studentdegreeid, qstudentview.studentid, qstudentview.org_id,
qstudents.sublevelid, qstudents.financeclosed, qstudents.finaceapproval
FROM qstudentview INNER JOIN qstudents ON qstudentview.qstudentid = qstudents.qstudentid
WHERE qstudentview.sublevelid = 'UGPM' AND qstudentview.quarterid = '2016/2017.2'
ORDER BY qstudentview.studentdegreeid;

SELECT qstudentid, studentdegreeid, studentid, org_id FROM qstudentview WHERE quarterid = '2016/2017.2M' AND studentdegreeid IN
(SELECT studentdegreeid FROM qstudentview WHERE sublevelid = 'UGPM' AND quarterid = '2016/2017.2')
ORDER BY studentdegreeid;

SELECT studentpayments.studentpaymentid, studentpayments.qstudentid, qstudents.studentdegreeid
FROM studentpayments INNER JOIN qstudents ON studentpayments.qstudentid = qstudents.qstudentid
WHERE qstudents.sublevelid = 'UGPM' AND qstudents.quarterid = '2016/2017.2';

SELECT studentpayments.studentpaymentid, qstudents.qstudentid, qstudents.studentdegreeid
FROM qstudents LEFT JOIN studentpayments ON qstudents.qstudentid = studentpayments.qstudentid
WHERE qstudents.quarterid = '2016/2017.2M' AND qstudents.studentdegreeid IN
(SELECT qstudents.studentdegreeid
FROM studentpayments INNER JOIN qstudents ON studentpayments.qstudentid = qstudents.qstudentid
WHERE qstudents.sublevelid = 'UGPM' AND qstudents.quarterid = '2016/2017.2');


UPDATE qstudents SET quarterid = '2016/2017.2M', org_id = 1 WHERE qstudentid = 275170;
UPDATE qstudents SET quarterid = '2016/2017.2M', org_id = 1 WHERE qstudentid = 274944;


SELECT qgradeid, gradeid FROM qgrades WHERE qstudentid IN
(SELECT qstudentid FROM qstudents WHERE sublevelid = 'UGPM' AND quarterid = '2016/2017.2');

ALTER TABLE qgrades DISABLE TRIGGER del_qgrades;
DELETE FROM qgrades WHERE qstudentid IN
(SELECT qstudentid FROM qstudents WHERE sublevelid = 'UGPM' AND quarterid = '2016/2017.2');
ALTER TABLE qgrades ENABLE TRIGGER del_qgrades;

DELETE FROM approvallist WHERE qstudentid IN
(SELECT qstudentid FROM qstudents WHERE sublevelid = 'UGPM' AND quarterid = '2016/2017.2');

DELETE FROM qstudents WHERE sublevelid = 'UGPM' AND quarterid = '2016/2017.2';

SELECT quarterid, qstudentid, studentid, studentdegreeid, sublevelid, studylevel
FROM qstudentview WHERE studentid IN ('70595', '73145');

SELECT studentid, studentdegreeid FROM studentdegrees WHERE studentid IN ('70595', '73145');

SELECT qstudentid
FROM qstudents
WHERE ((financeclosed = true) OR (finaceapproval = true)) AND quarterid = '2016/2017.2M' AND qresidenceid is null;

SELECT quarterid, qstudentid, active, studentname, studentid, org_id FROM vwqstudentbalances WHERE qstudentid


-------- Medical
SELECT qstudentid, studentdegreeid, studentid, org_id FROM qstudentview WHERE sublevelid = 'MEDI' AND quarterid = '2016/2017.2'
ORDER BY studentdegreeid;

SELECT qstudentview.qstudentid, qstudentview.studentdegreeid, qstudentview.studentid, qstudentview.org_id,
qstudents.sublevelid, qstudents.financeclosed, qstudents.finaceapproval
FROM qstudentview INNER JOIN qstudents ON qstudentview.qstudentid = qstudents.qstudentid
WHERE qstudentview.sublevelid = 'MEDI' AND qstudentview.quarterid = '2016/2017.2'
ORDER BY qstudentview.studentdegreeid;

SELECT qstudentid, studentdegreeid, studentid, org_id FROM qstudentview WHERE quarterid = '2016/2017.2M' AND studentdegreeid IN
(SELECT studentdegreeid FROM qstudentview WHERE sublevelid = 'MEDI' AND quarterid = '2016/2017.2')
ORDER BY studentdegreeid;

SELECT studentpayments.studentpaymentid, studentpayments.qstudentid, qstudents.studentdegreeid
FROM studentpayments INNER JOIN qstudents ON studentpayments.qstudentid = qstudents.qstudentid
WHERE qstudents.sublevelid = 'MEDI' AND qstudents.quarterid = '2016/2017.2';

SELECT studentpayments.studentpaymentid, qstudents.qstudentid, qstudents.studentdegreeid
FROM qstudents LEFT JOIN studentpayments ON qstudents.qstudentid = studentpayments.qstudentid
WHERE qstudents.quarterid = '2016/2017.2M' AND qstudents.studentdegreeid IN
(SELECT qstudents.studentdegreeid
FROM studentpayments INNER JOIN qstudents ON studentpayments.qstudentid = qstudents.qstudentid
WHERE qstudents.sublevelid = 'MEDI' AND qstudents.quarterid = '2016/2017.2');

SELECT qgradeid, gradeid FROM qgrades WHERE qstudentid IN
(SELECT qstudentid FROM qstudents WHERE sublevelid = 'MEDI' AND quarterid = '2016/2017.2');

ALTER TABLE qgrades DISABLE TRIGGER del_qgrades;
DELETE FROM qgrades WHERE qstudentid IN
(SELECT qstudentid FROM qstudents WHERE sublevelid = 'MEDI' AND quarterid = '2016/2017.2');
ALTER TABLE qgrades ENABLE TRIGGER del_qgrades;

DELETE FROM approvallist WHERE qstudentid IN
(SELECT qstudentid FROM qstudents WHERE sublevelid = 'MEDI' AND quarterid = '2016/2017.2');

DELETE FROM qstudents WHERE sublevelid = 'MEDI' AND quarterid = '2016/2017.2';



ALTER TABLE qgrades DISABLE TRIGGER del_qgrades;
DELETE FROM qgrades WHERE qstudentid = 286831;
ALTER TABLE qgrades ENABLE TRIGGER del_qgrades;


------------------ Grade upgrades

ALTER TABLE qstudents DISABLE TRIGGER ins_qstudents;
ALTER TABLE qgrades DISABLE TRIGGER ins_qgrades;

UPDATE qstudents SET quarterid = '2016/2017.1M' WHERE quarterid = '2016/2017.1' AND sublevelid = 'UGPM';

UPDATE qstudents SET org_id = 1 WHERE quarterid = '2016/2017.1M';
UPDATE qstudents SET org_id = 1 WHERE quarterid = '2016/2017.2M';

UPDATE qgrades SET org_id = 0 WHERE qstudentid IN
(SELECT qstudentid FROM qstudents WHERE qstudents.sublevelid = 'UGPM' AND qstudents.quarterid = '2016/2017.1M');
UPDATE qgrades SET org_id = 0 WHERE qstudentid IN
(SELECT qstudentid FROM qstudents WHERE qstudents.sublevelid = 'UGPM' AND qstudents.quarterid = '2016/2017.2M');

UPDATE qgrades SET gradeid = getdbgradeid(round(finalmarks)::integer, 0)
WHERE qstudentid IN (SELECT qstudentid FROM qstudents WHERE qstudents.sublevelid = 'UGPM' AND qstudents.quarterid = '2016/2017.2M');

ALTER TABLE qstudents ENABLE TRIGGER ins_qstudents;
ALTER TABLE qgrades ENABLE TRIGGER ins_qgrades;

-------------------- Checks

SELECT qstudentview.qstudentid, qstudentview.studentdegreeid, qstudentview.studentid, qstudentview.org_id,
qstudents.sublevelid, qstudents.quarterid, qstudents.financeclosed, qstudents.finaceapproval
FROM qstudentview INNER JOIN qstudents ON qstudentview.qstudentid = qstudents.qstudentid
WHERE qstudentview.studentid = '75154'
ORDER BY qstudentview.studentdegreeid;


UPDATE qstudents SET sublevelid = studentdegrees.sublevelid, org_id = studentdegrees.org_id
FROM studentdegrees
WHERE (qstudents.sublevelid is null) AND (qstudents.studentdegreeid = studentdegrees.studentdegreeid);


