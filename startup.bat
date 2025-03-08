@echo off

:: Ask the user if they want to install the requirements
set /p INSTALL_REQ="Do you want to install the requirements from requirements.txt? (on/off): "

:: Step 1: Create a virtual environment
echo Creating virtual environment...
python -m venv venv

:: Step 2: Activate the virtual environment
echo Activating virtual environment...
call venv\Scripts\activate

:: Step 3: Conditionally install dependencies based on user input
if /i "%INSTALL_REQ%"=="on" (
    echo Installing dependencies from requirements.txt...

    :: Install dependencies from requirements.txt (no --progress-bar option)
    pip install -r requirements.txt
) else (
    echo Skipping the installation of dependencies.
)

:: Step 4: Run your Python script
echo Running Python script...
streamlit run lostnfound.py