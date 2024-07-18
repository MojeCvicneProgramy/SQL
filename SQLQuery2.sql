
 SELECT TOP (3500) P.[RC] AS [Os. èís.] 

,P.[PoradoveCisloPP] AS [PV] 

             ,P.[IntrawebLogin] AS [Login] 

               --,I.[NS] 

               --,P.Stredisko 

               ,isnull(P.[Prijmeni],'')  + ' ' + isnull(P.[Jmeno],'')  + ' ' + isnull(P.[Titul],'') AS [Meno]  

             ,P.[FunkcePopis] AS [Funkcia - text] 

 ,isnull(CONVERT(NVARCHAR,P.[DatumVystupu],104),'') AS [Dátum skonèenia] --convert zmení datetime na formát dd.mm.yyy a isnull skontroluje èi je NULL v bunke a ak áno, tak ju zmení na prázdny string 

 

 ,isnull(CONVERT(NVARCHAR,P.[DatumNastupu],104),'') AS [Datum vzniku PV] 

              

             ,replace(P.[DovolenaNarokCelkem],'.', ',') AS [Nárok dovolenky] 

             ,replace(P.[DovolenaZustatek],'.', ',') AS [Zostatok dovolenky k poslednej uzávierke] 

             --,P.[DovolenaNarCerp] 

             --,P.[DovolenaDodatCerp] 

             --,P.[DovolenaOsobCerp] 

             --,P.[DovolenaDalsiCerp] 

             -- ,I.[Narok] 

               ,isnull(SUM([Plan]), 0) AS [Naplánované dni dovolenky v obd. do konca roka (údaj z plánovania dovoleniek v DS RON)] 

               ,(cast(isnull(P.[DovolenaZustatek],'0') AS INT) - cast(isnull(SUM([Plan]),'0') AS INT)) AS [Rozdiel medzi zostatkom dovolenky a poètom naplánovaných dní dovolenky] 

             --,H.[EvidStavKod] AS [Druh Vyòatia èíslo] 

-- ,V.[dr_vyn_popis] AS [popis vyòatia] 

 ,CASE 

 WHEN V.[dr_vyn_popis] = 'Nie je vyòatý' THEN REPLACE(V.[dr_vyn_popis], 'Nie je vyòatý', '') 

 ELSE V.[dr_vyn_popis] 

 END AS [Druh vyòatia] 

 

             ,isnull(CONVERT(NVARCHAR,H.[EvStavOd],104),'') AS [Dátum vyòatia zo stavu - MDRD] 

             ,isnull(CONVERT(NVARCHAR,H.[EvStavDo],104),'') AS [Dátum návratu po MDRD] 

        

         FROM [XX].[pr].[dbo].[ron] AS P 

         LEFT JOIN [IntranetAspNet].[ron].[PlanDov] AS I 

         ON P.[OsobniCislo] = I.[OsobniCislo] 

               --plán dovolenky od konca minulého mesiaca do konca roku 

         AND I.[RokMesiac] between (cast(format(getdate(),'yyyyMM') as int)) AND (cast(format(getdate(),'yyyy12') as int)) 

  

         LEFT JOIN [XX].[pr].[dbo].[hhr_prv] AS H 

         ON P.[OsobniCislo] = H.[OsCislo] 

 

 LEFT JOIN [XX].[pr].[dbo].[z_vynatie] AS V 

         ON H.[EvidStavKod] = V.[dr_vyn_cis] 

 

  

         WHERE  

 

             --PP na dobu neurèitú alebo ukonèenie neskôr ako do konca minulého mesiaca 

        P.[DatumVystupu] is null 

        OR (P.[DatumVystupu] > eomonth(dateadd(month, -1, getdate()))) 

--OR P.[FunkcePopis] not IN ('brigádnik', 'ŽOV%') 

        

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

  

     

         HAVING P.[FunkcePopis] not IN ( 'brigádnik' 

 , 'Brigádnik / stážista II na CEN a CS' 

, 'Brigádnik / stážista na CEN a CS / hod.'  

, 'ŽOV I.roèník' 

,'ŽOV II.roèník' 

,'ŽOV III.roèník' 

,'ŽOV IV.roèník') 

  

         ORDER BY P.RC 