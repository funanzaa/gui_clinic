import psycopg2
from configparser import ConfigParser
import os
from pathlib import Path


class DataBase:
    def __init__(self):
        self.config_object = ConfigParser()
        self.config_object.read(r"config\config.ini")
        self.serverinfo = self.config_object["SERVERCONFIG"]
        self.dbname = self.serverinfo["dbname"]
        self.user = self.serverinfo["user"]
        self.host = self.serverinfo["host"]
        self.port = self.serverinfo["port"]
        self.password = self.serverinfo["passwd"]

    def export(self, file, dateform, dateto , dir):

        dateto_format = str(dateto.strftime("%y%m"))

        formatDateForm =  str(dateform.strftime("%m-%d"))
        formatDateTo = str(dateto.strftime("%m-%d"))

        yearForm = str(int(dateform.strftime("%Y")) + 543)
        yearDateTo = str(int(dateto.strftime("%Y")) + 543)

        dateFormBuda = "{}-{}".format(yearForm, formatDateForm)
        dateToBuda = "{}-{}".format(yearDateTo, formatDateTo)


        # with open("sql\{}.sql".format(file), mode="r", encoding="utf8") as f:
            # sql = f.read()

        data_folder = Path("sql/")
        file_to_open = data_folder / "{}.sql".format(file)
        # print(file_to_open)

        # sql = open(file_to_open)

        with open(file_to_open, mode="r", encoding="utf8") as f:
            sql = f.read()

            paramInSQL = sql.format("'" + str(dateFormBuda) + "'", "'" + str(dateToBuda) + "'")

        # print(paramInSQL)

        connection = psycopg2.connect(user=self.user, password=self.password, host=self.host, port=self.port,
                                      database=self.dbname)

        db_cursor = connection.cursor()

        # Use the COPY function on the SQL we created above.
        SQL_for_file_output = "COPY ({0}) TO STDOUT WITH DELIMITER '|' CSV HEADER null as E' '".format(paramInSQL)

        # Set up a variable to store our file path and name.
        t_path_n_file = dir + "/" + file + dateto_format + ".txt"

        # Trap errors for opening the file
        try:
            with open(t_path_n_file, 'w', encoding="utf8") as f_output:
                db_cursor.copy_expert(SQL_for_file_output, f_output)

        except psycopg2.Error as e:
            print(e)

        db_cursor.close()
        connection.close()
        return True