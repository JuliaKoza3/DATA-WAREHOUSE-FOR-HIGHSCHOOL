use DataWarehouses

INSERT INTO [dbo].[DimJunk] 
SELECT p, a, r 
FROM (
  VALUES 
   ('Passed'),
   ('NotPassed')
	  ) 
  AS Passed(p),	
	 (
      VALUES 
	  ('Anulled'),
	  ('NotAnulled')
	  ) 
  AS Annulled(a),
	  (
	  VALUES 
	  ('Retake'),
	  ('NotRetake')
	  ) 
  AS Retake(r)
	



