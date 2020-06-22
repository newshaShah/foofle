import java.sql.*;
import java.util.Scanner;

class Main{
    public static void main(String args[]){
        Scanner scanner = new Scanner(System.in);
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/foofle?useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC";
            String user = "root";
            String pass = "";
            Connection con=DriverManager.getConnection(url,user,pass);
            if(con!=null) System.out.println("connection successful");
            System.out.println();


            System.out.println("\t\twelcome to foofle database!");

            System.out.println();

            System.out.println("-------------------------------------------------------------------------------------------");
            System.out.println("    0  --------- <Exit the program> ");
            System.out.println("    1  --------- <Add a new user to database> ");
            System.out.println("    2  --------- <Login to your account> ");
            System.out.println("    3  --------- <Get news of your account> ");
            System.out.println("    4  --------- <Get your account information including system and personal information");
            System.out.println("    5  --------- <Get other account information> ");
            System.out.println("    6  --------- <Edit your account> ");
            System.out.println("    7  --------- <Delete your account> ");
            System.out.println("    8  --------- <Send email> ");
            System.out.println("    9  --------- <Get your email inbox> ");
            System.out.println("    10 --------- <Read a specific email from inbox> ");
            System.out.println("    11 --------- <Read a specific sent email> ");
            System.out.println("    12 --------- <Get your sent emails> ");
            System.out.println("    13 --------- <Delete a specific email from inbox> ");
            System.out.println("    14 --------- <Delete a specific sent email> ");
            System.out.println("    15 --------- <Block a user so this user wouldn't be able to see your account information> ");
            System.out.println("    16 --------- <Unblock a user so this user can see see your account information> ");
            System.out.println("-------------------------------------------------------------------------------------------");
            boolean flag = true;
            while(flag){

                System.out.println();
                System.out.println("Enter function code: ");




                int func = scanner.nextInt();
                switch (func){
                    case 0:
                        flag = false;
                        break;

                    case 1:
                        String query =  "{CALL add_user(?,?,?,?,?,?,?,?,?,?)}";
                        CallableStatement stmt = con.prepareCall(query);
                        System.out.print("First name: ");
                        String firstName = scanner.next();
                        System.out.print("Last name: ");
                        String lastName = scanner.next();
                        System.out.print("Alias: ");
                        String alias = scanner.next();
                        System.out.print("Address: ");
                        String address = scanner.next();
                        System.out.print("Birth date: ");
                        String birthDate = scanner.next();
                        System.out.print("Phone: ");
                        String phone = scanner.next();
                        System.out.print("National id: ");
                        String nId = scanner.next();
                        System.out.print("Username: ");
                        String username = scanner.next();

                        System.out.print("Password: ");
                        String password = scanner.next();
                        System.out.print("Account phone: ");
                        String accountPhone = scanner.next();


                        stmt.setString(1, firstName);
                        stmt.setString(2, lastName);
                        stmt.setString(3, alias);
                        stmt.setString(4, address);
                        stmt.setString(5, birthDate);
                        stmt.setString(6, phone);
                        stmt.setString(7, nId);
                        stmt.setString(8, username);
                        stmt.setString(9, password);
                        stmt.setString(10, accountPhone);

                        ResultSet r = stmt.executeQuery();
                        while(r.next())
                            System.out.println(r.getString(1));
                        System.out.println();

                        break;
                    case 2:
                        query =  "{CALL login(?,?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Username: ");
                        username = scanner.next();
                        System.out.println();
                        System.out.print("Password: ");
                        password = scanner.next();
                        stmt.setString(1, username);
                        stmt.setString(2, password);

                        r = stmt.executeQuery();
                        while(r.next())
                            System.out.println(r.getString(1));
                        System.out.println();


                        break;
                    case 3:
                        query =  "{CALL get_news()}";
                        stmt = con.prepareCall(query);
                        r = stmt.executeQuery();

                        Object[] row0 = new String[]{"text","time"};
                        System.out.format("%70s%70s\n", row0);
                        System.out.println("+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+");
                        while(r.next()) {
                            Object[] row = new String[2];
                            for (int i = 1; i <3; i++) {
                                row[i-1] = r.getString(i);

                            }
                            System.out.format("%70s%70s\n", row);
                        }
                        System.out.println();
                        break;
                    case 4:
                        query =  "{CALL get_my_inf()}";
                        stmt = con.prepareCall(query);
                        r = stmt.executeQuery();


                        row0 = new String[]{"firstName","lastName","alias","address","birth date","phone","national id","username","accountPhone","creation date"};
                        System.out.format("%5s%15s%15s%25s%17s%15s%15s%15s%15s%30s\n", row0);
                        System.out.println("+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+");
                        while(r.next()) {
                            Object[] row = new String[10];
                            for (int i = 1; i <11; i++) {
                                row[i-1] = r.getString(i);

                            }
                            System.out.format("%5s%15s%15s%30s%15s%15s%15s%15s%15s%30s\n", row);
                           }
                        System.out.println();
                        break;
                    case 5:
                        query =  "{CALL get_others_inf(?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Enter account username : ");
                         username = scanner.next();
                        stmt.setString(1, username);
                        r = stmt.executeQuery();
                        try{
                             row0 = new String[]{"firstName","lastName","alias","address","birth date","phone","national id","username"};
                            System.out.format("%15s%15s%15s%20s%15s%15s%15s%15s\n", row0);
                            System.out.println("+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+");
                            while(r.next()) {
                                Object[] row = new String[8];
                                for (int i = 1; i < 9; i++)
                                    row[i - 1] = r.getString(i);


                                System.out.format("%15s%15s%15s%20s%15s%15s%15s%15s\n", row);
                            }

                        } catch (SQLException e) {

                            System.out.println(r.getString(1));


                        }


                        break;
                    case 6:
                        query =  "{CALL edit_account(?,?,?,?,?,?,?,?,?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("First name: ");
                        firstName = scanner.next();
                        System.out.print("Last name: ");
                         lastName = scanner.next();
                        System.out.print("Alias: ");
                        alias = scanner.next();
                        System.out.print("Address: ");
                         address = scanner.next();
                        System.out.print("Birth date: ");
                         birthDate = scanner.next();
                        System.out.print("Phone: ");
                        phone = scanner.next();
                        System.out.print("National id: ");
                        nId = scanner.next();
                        System.out.print("Password: ");
                        password = scanner.next();
                        System.out.print("Account phone: ");

                        accountPhone = scanner.next();

                        stmt.setString(1, firstName);
                        stmt.setString(2, lastName);
                        stmt.setString(3, alias);
                        stmt.setString(4, address);
                        stmt.setString(5, birthDate);
                        stmt.setString(6, phone);
                        stmt.setString(7, nId);
                        stmt.setString(8, password);
                        stmt.setString(9, accountPhone);

                        stmt.executeQuery();





                        break;
                    case 7:
                        query =  "{CALL delete_account()}";
                        stmt = con.prepareCall(query);
                        stmt.executeQuery();
                        break;
                    case 8:
                        query =  "{CALL send_email(?,?,?,?,?,?,?,?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Subject: ");
                        String subject = scanner.next();
                        System.out.print("Text: ");
                        scanner.nextLine();
                        String text = scanner.nextLine();
                        System.out.println("You can fill as many field as you want for receivers: ");
                        System.out.print("Username of receiver 1: ");
                        String receiver1 = scanner.nextLine();
                        System.out.print("Username of receiver 2: ");
                        String receiver2 = scanner.nextLine();
                        System.out.print("Username of receiver 3: ");
                        String receiver3 = scanner.nextLine();
                        System.out.print("Username of CC receiver 1: ");
                        String receivercc1 = scanner.nextLine();
                        System.out.print("Username of CC receiver 2: ");
                        String receivercc2 = scanner.nextLine();
                        System.out.print("Username of CC receiver 3: ");
                        String receivercc3 = scanner.nextLine();



                        stmt.setString(1, subject);
                        stmt.setString(2, text);
                        stmt.setString(3, receiver1);
                        stmt.setString(4, receiver2);
                        stmt.setString(5, receiver3);
                        stmt.setString(6, receivercc1);
                        stmt.setString(7, receivercc2);
                        stmt.setString(8, receivercc3);

                        r = stmt.executeQuery();
                        try{
                               while(r.next()) {

                                System.out.format(r.getString(1));
                            }

                        } catch (SQLException ignored) {

                        }




                        break;
                    case 9:

                        query =  "{CALL email_inbox(?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Page: ");
                        String page = scanner.next();
                        stmt.setString(1, page);
                        r = stmt.executeQuery();

                        row0 = new String[]{"sender","subject","time","isRead"};
                        System.out.format("%30s%30s%30s\n", row0);
                        System.out.println("+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+");
                        while(r.next()) {
                            Object[] row = new String[3];
                            for (int i = 1; i < 4; i++)
                                row[i - 1] = r.getString(i);


                            System.out.format("%30s%30s%30s\n", row);
                        }

                        break;
                    case 10:
                        query =  "{CALL read_inbox_email(?,?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Enter username of email sender: ");
                        String sender = scanner.next();
                        System.out.print("Enter exact time of your received email: ");
                        scanner.nextLine();
                        String time = scanner.nextLine();

                        stmt.setString(1, sender);
                        stmt.setString(2, time);
                        r = stmt.executeQuery();
                        while(r.next()) {


                            System.out.println(r.getString(1));
                        }


                        break;
                    case 11:
                        query =  "{CALL read_sent_email(?)}";
                        stmt = con.prepareCall(query);

                        System.out.print("Enter exact time of email you have sent: ");
                        scanner.nextLine();
                        time = scanner.nextLine();


                        stmt.setString(1, time);
                        r = stmt.executeQuery();
                        while(r.next()) {


                            System.out.println(r.getString(1));
                        }
                        break;
                    case 12:
                        query =  "{CALL email_sent(?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Page: ");
                         page = scanner.next();
                        stmt.setString(1, page);
                        r = stmt.executeQuery();


                        row0 = new String[]{"subject","time","receiver","isRead","isCC"};
                        System.out.format("%30s%30s%30s%30s%30s\n", row0);
                        System.out.println("+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+");
                        while(r.next()) {
                            Object[] row = new String[5];
                            for (int i = 1; i < 6; i++)
                                row[i - 1] = r.getString(i);


                            System.out.format("%30s%30s%30s%30s%30s\n", row);
                        }


                        break;
                    case 13:
                        query =  "{CALL delete_inbox_email(?,?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Enter username of email sender: ");
                         sender = scanner.next();
                        System.out.print("Enter exact time of your received email: ");
                        scanner.nextLine();
                         time = scanner.nextLine();

                        stmt.setString(1, sender);
                        stmt.setString(2, time);
                         stmt.executeQuery();



                        break;

                    case 14:
                        query =  "{CALL delete_sent_email(?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Enter exact time of your received email: ");
                        scanner.nextLine();
                        time = scanner.nextLine();
                        stmt.setString(1, time);
                        stmt.executeQuery();
                        break;
                    case 15:
                        query =  "{CALL block_user(?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Which username do you want to block: ");
                        username = scanner.next();


                        stmt.setString(1, username);


                        r=stmt.executeQuery();
                        while(r.next())
                            System.out.println(r.getString(1));
                        System.out.println();
                        break;

                    case 16:

                        query =  "{CALL unblock_user(?)}";
                        stmt = con.prepareCall(query);
                        System.out.print("Which username do you want to unblock: ");
                        username = scanner.next();


                        stmt.setString(1, username);


                        r = stmt.executeQuery();
                        while(r.next())
                            System.out.println(r.getString(1));
                        System.out.println();




                        break;


                    default:
                        System.out.println("Wrong input try again");

                }



            }


        }catch(Exception e){ System.out.println(e);}
    }
}