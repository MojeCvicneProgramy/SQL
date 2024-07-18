
 SELECT TOP (3500) P.[RC] AS [Os. ��s.] 

,P.[PoradoveCisloPP] AS [PV] 

             ,P.[IntrawebLogin] AS [Login] 

               --,I.[NS] 

               --,P.Stredisko 

               ,isnull(P.[Prijmeni],'')  + ' ' + isnull(P.[Jmeno],'')  + ' ' + isnull(P.[Titul],'') AS [Meno]  

             ,P.[FunkcePopis] AS [Funkcia - text] 

 ,isnull(CONVERT(NVARCHAR,P.[DatumVystupu],104),'') AS [D�tum skon�enia] --convert zmen� datetime na form�t dd.mm.yyy a isnull skontroluje �i je NULL v bunke a ak �no, tak ju zmen� na pr�zdny string 

 

 ,isnull(CONVERT(NVARCHAR,P.[DatumNastupu],104),'') AS [Datum vzniku PV] 

              

             ,replace(P.[DovolenaNarokCelkem],'.', ',') AS [N�rok dovolenky] 

             ,replace(P.[DovolenaZustatek],'.', ',') AS [Zostatok dovolenky k poslednej uz�vierke] 

             --,P.[DovolenaNarCerp] 

             --,P.[DovolenaDodatCerp] 

             --,P.[DovolenaOsobCerp] 

             --,P.[DovolenaDalsiCerp] 

             -- ,I.[Narok] 

               ,isnull(SUM([Plan]), 0) AS [Napl�novan� dni dovolenky v obd. do konca roka (�daj z pl�novania dovoleniek v DS RON)] 

               ,(cast(isnull(P.[DovolenaZustatek],'0') AS INT) - cast(isnull(SUM([Plan]),'0') AS INT)) AS [Rozdiel medzi zostatkom dovolenky a po�tom napl�novan�ch dn� dovolenky] 

             --,H.[EvidStavKod] AS [Druh Vy�atia ��slo] 

-- ,V.[dr_vyn_popis] AS [popis vy�atia] 

 ,CASE 

 WHEN V.[dr_vyn_popis] = 'Nie je vy�at�' THEN REPLACE(V.[dr_vyn_popis], 'Nie je vy�at�', '') 

 ELSE V.[dr_vyn_popis] 

 END AS [Druh vy�atia] 

 

             ,isnull(CONVERT(NVARCHAR,H.[EvStavOd],104),'') AS [D�tum vy�atia zo stavu - MDRD] 

             ,isnull(CONVERT(NVARCHAR,H.[EvStavDo],104),'') AS [D�tum n�vratu po MDRD] 

        

         FROM [XX].[pr].[dbo].[ron] AS P 

         LEFT JOIN [IntranetAspNet].[ron].[PlanDov] AS I 

         ON P.[OsobniCislo] = I.[OsobniCislo] 

               --pl�n dovolenky od konca minul�ho mesiaca do konca roku 

         AND I.[RokMesiac] between (cast(format(getdate(),'yyyyMM') as int)) AND (cast(format(getdate(),'yyyy12') as int)) 

  

         LEFT JOIN [XX].[pr].[dbo].[hhr_prv] AS H 

         ON P.[OsobniCislo] = H.[OsCislo] 

 

 LEFT JOIN [XX].[pr].[dbo].[z_vynatie] AS V 

         ON H.[EvidStavKod] = V.[dr_vyn_cis] 

 

  

         WHERE  

 

             --PP na dobu neur�it� alebo ukon�enie nesk�r ako do konca minul�ho mesiaca 

        P.[DatumVystupu] is null 

        OR (P.[DatumVystupu] > eomonth(dateadd(month, -1, getdate()))) 

--OR P.[FunkcePopis] not IN ('brig�dnik', '�OV%') 

        

       GROUP BY P.[RC],P.[PoradoveCisloPP]--,I.[NS] 

              -- ,P.Stredisko 

             ,P.[IntrawebLogin] 

               ,P.[Prijmeni], P.[Jmeno], P.[Titul] 

             ,P.[DatumNastupu] 

             ,P.[DatumVystupu] 

             ,P.[FunkcePopis] 

             -- ,I.[Narok] 

             ,P.[DovolenaNarokCelkem] 

             ,P.[DovolenaZustatek] 

             --,P.[DovolenaNarCerp] 

             --,P.[DovolenaDodatCerp] 

             --,P.[DovolenaOsobCerp] 

             --,P.[DovolenaDalsiCerp] 

             --,H.[EvidStavKod] 

 ,V.[dr_vyn_popis] 

             ,H.[EvStavOd] 

             ,H.[EvStavDo] 

  

     

         HAVING P.[FunkcePopis] not IN ( 'brig�dnik' 

 , 'Brig�dnik / st�ista II na CEN a CS' 

, 'Brig�dnik / st�ista na CEN a CS / hod.'  

, '�OV I.ro�n�k' 

,'�OV II.ro�n�k' 

,'�OV III.ro�n�k' 

,'�OV IV.ro�n�k') 

  

         ORDER BY P.RC 