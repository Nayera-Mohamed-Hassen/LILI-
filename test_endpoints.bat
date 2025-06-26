@echo off
REM Static user and house IDs provided
set USER_ID=d99f7950-2254-44ad-8ec9-1fdb9ed661c5
set HOUSE_ID=87bcfd38-9b88-468e-97e3-b4ce1cf3a485

REM Output file
set OUTFILE=api_test_results.txt
echo Testing LILI API Endpoints > %OUTFILE%
echo. >> %OUTFILE%

REM Root endpoint
echo Testing / >> %OUTFILE%
curl -w "Time: %%{time_total}s\n" -o NUL -s "http://localhost:8000/" >> %OUTFILE%
echo. >> %OUTFILE%

REM User profile
echo Testing /profile/{user_id} >> %OUTFILE%
curl -w "Time: %%{time_total}s\n" -o NUL -s "http://localhost:8000/profile/%USER_ID%" >> %OUTFILE%
echo. >> %OUTFILE%

REM Allergies
echo Testing /allergies/{user_id} >> %OUTFILE%
curl -w "Time: %%{time_total}s\n" -o NUL -s "http://localhost:8000/allergies/%USER_ID%" >> %OUTFILE%
echo. >> %OUTFILE%

REM Household
echo Testing /household/{house_id} >> %OUTFILE%
curl -w "Time: %%{time_total}s\n" -o NUL -s "http://localhost:8000/household/%HOUSE_ID%" >> %OUTFILE%
echo. >> %OUTFILE%

REM Favorites
echo Testing /favorites/{user_id} >> %OUTFILE%
curl -w "Time: %%{time_total}s\n" -o NUL -s "http://localhost:8000/favorites/%USER_ID%" >> %OUTFILE%
echo. >> %OUTFILE%

REM Calendar events
echo Testing /calendar/events?user_id={user_id} >> %OUTFILE%
curl -w "Time: %%{time_total}s\n" -o NUL -s "http://localhost:8000/calendar/events?user_id=%USER_ID%" >> %OUTFILE%
echo. >> %OUTFILE%

REM Transactions
echo Testing /transactions/{user_id} >> %OUTFILE%
curl -w "Time: %%{time_total}s\n" -o NUL -s "http://localhost:8000/transactions/%USER_ID%" >> %OUTFILE%
echo. >> %OUTFILE%

REM OCR test endpoint
echo Testing /ocr/test >> %OUTFILE%
curl -w "Time: %%{time_total}s\n" -o NUL -s -X POST "http://localhost:8000/ocr/test" >> %OUTFILE%
echo. >> %OUTFILE%

REM Print results to console
type %OUTFILE%
pause 