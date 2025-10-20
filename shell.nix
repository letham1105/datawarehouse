{ pkgs ? import <nixpkgs> {} }:

let
	# Use a specific nixpkgs-unstable commit for newer podman-compose
	pkgs-unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-unstable.tar.gz") {};

	python-with-packages = pkgs-unstable.python312.withPackages (ps: [
		ps.pandas
		ps.sqlalchemy
		ps.psycopg2-binary
		ps.streamlit
		ps.plotly
		ps.pip
		# ps.dbt-postgres
		ps.kaggle
		ps.python-dotenv
	]);
in

	pkgs.mkShell {
		packages = [

			python-with-packages
			pkgs.postgresql_17_jit
			pkgs.lsof
			pkgs.podman
			pkgs.podman-compose
		];
		shellHook = ''
		echo "PostgreSQL and Python 3.13 environment ready"
		export PGDATA=$PWD/pgdata


		echo "--- Datawarehouse Shell ---"
		export PGDATA=$PWD/pgdata

		# Define a helper function
		start_db() {
		# 1. Check if DB is initialized
		if [ ! -f "$PGDATA/PG_VERSION" ]; then
		echo "ERROR: Database not initialized in $PGDATA"
		echo "Please run this command FIRST:"
		echo "initdb -D $PGDATA --no-locale --encoding=UTF8 -U postgres"
		return 1
		fi

		# 2. Check if DB is already running (using lsof)
		if lsof -i :5432 -sTCP:LISTEN -t >/dev/null; then
		echo "PostgreSQL is already running on port 5432."
		return 0
		fi

		# 3. Start the DB
		echo "Starting PostgreSQL..."
		postgres -D $PGDATA &
		}

		# Welcome message
		echo "To start PostgreSQL, run command: start_db"
		echo "PGDATA is set to: $PGDATA"
		echo "-----------------------------"

		'';
		# inputsFrom = [
		# 	pkgs.bat
		# ]
	}
