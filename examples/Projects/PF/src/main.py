import sys
import os

class EcgMain:

    def __init__(self, fs_type):
        self.fs_type = fs_type

    def run_command(self, command):
        result = os.system(command)
        if result != 0:
            print(f"Command failed with exit code {result}")
        else:
            print("Command executed successfully")

    def run_job(self, path):
        cmd = f'src/{path}/run.sh {self.fs_type}'
        print(cmd)
        self.run_command(cmd)
     
    def display_menu(self):
        print("\n" + "="*30)
        print("         MAIN MENU")
        print("="*30)
        print("1. Template Segmentation")
        print("2. Template Counter")
        print("3. Filter Templates")
        print("4. Outlier Detection")
        print("5. Outliers Counter")
        print("6. Filter Outliers") #pesquisar por user, ts, limit TODO
        print("0. Exit")
        print("="*30)
    
    def run(self):
        while True:
            self.display_menu()
            choice = input("Enter your choice (0-6): ")
            if choice == '1':
                self.run_job('templateSegmentation')
            elif choice == '2':
                self.run_job('templateSegmentationCounter')
            elif choice == '3':
                self.run_job('showTemplates')
            elif choice == '4':
                self.run_job('outlierDetection')
            elif choice == '5':
                self.run_job('outliersCounter')
            elif choice == '6':
                self.run_job('showOutliers')
            elif choice == '0':
                print("\nExiting... Goodbye!\n")
                break
            else:
                print("\nInvalid choice, please try again.\n")


if __name__ == "__main__":
    fs_type = sys.argv[1]
    EcgMain(fs_type).run()