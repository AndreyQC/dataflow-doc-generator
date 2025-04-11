###Create a virtual environment

- Create a virtual environment by running the following command
  
  On Windows :

        python -m venv env

  On Linux/macOS

        python3 -m venv env

- Activate the virtual environment. Run the below at the prompt from the folder where you created the virtual environment

        ./env/Scripts/activate

- Once successfully activated the terminal prompt changes to

        (env) PS C:\repos\personal\scores-manager-ui-pyside>

- Install requirements

        pip3 install -r requirements.txt       


        pip3 freeze > requirements.txt

- Packages
  
        pip install pyside6
        pip install ruamel.yaml
        pip install psycopg2


 Install venv:
	python -m venv venv
	2. Activate venv:
	.env\Scripts\activate
	3. Install UV:
	pip install uv
	4. Initialize the project: uv init
	5. For install the packages: uv add …
	- uv add pre-commit
- pre-commit install