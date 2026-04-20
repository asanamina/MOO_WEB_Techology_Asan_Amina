CREATE SCHEMA IF NOT EXISTS library_amina_db;
SET search_path TO library_amina_db;

CREATE TABLE IF NOT EXISTS library_amina_db.Genres (
	GenresID SERIAL PRIMARY KEY,
	GenresName VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS library_amina_db.Books (
	BookID SERIAL PRIMARY KEY,
	BookName VARCHAR(50) NOT NULL UNIQUE,
	BooksPublicationYear INT CHECK (BooksPublicationYear > 0),
	ISBN CHAR(13) UNIQUE NOT NULL 
);

CREATE TABLE IF NOT EXISTS library_amina_db.Authors (
	AuthorsID SERIAL PRIMARY KEY,
	FirstName VARCHAR(100),
	LastName VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS library_amina_db.BookAuthors (
	BookID INT, 
	AuthorsID INT,
	PRIMARY KEY (BookID, AuthorsID),
	FOREIGN KEY (BookID) REFERENCES library_amina_db.Books (BookID),
	FOREIGN KEY (AuthorsID) REFERENCES library_amina_db.Authors (AuthorsID)
);

CREATE TABLE IF NOT EXISTS library_amina_db.BookGenre (
	BookID INT, 
	GenresID INT, 
	PRIMARY KEY (BookID, GenresID),
	FOREIGN KEY (BookID) REFERENCES library_amina_db.Books (BookID),
	FOREIGN KEY (GenresID) REFERENCES library_amina_db.Genres (GenresID)
);

CREATE TABLE IF NOT EXISTS library_amina_db.Borrowers (
	BorrowerID SERIAL PRIMARY KEY,
	FirstName VARCHAR(100) NOT NULL,
	LastName VARCHAR(100) NOT NULL,
	Email VARCHAR(255) UNIQUE NOT NULL, 
	Phone VARCHAR(15) UNIQUE NOT NULL,
	RegistrationDate DATE NOT NULL 
);

CREATE TABLE IF NOT EXISTS library_amina_db.LibraryStaff (
	StaffID SERIAL PRIMARY KEY,
	FirstName VARCHAR(100) NOT NULL,
	LastName VARCHAR(100) NOT NULL,
	BirthDate DATE NOT NULL CHECK (BirthDate < current_date),
	Job VARCHAR(50) NOT NULL,
	Phone VARCHAR (15) UNIQUE NOT NULL, 
	Email VARCHAR (100) UNIQUE NOT NULL,
	Address VARCHAR (255) NOT NULL, 
	EmploymentDate DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS library_amina_db.BookCopies (
	CopyID SERIAL PRIMARY KEY,
	BookID INT NOT NULL,
	Barcode VARCHAR (50) UNIQUE NOT NULL,
	Shelf VARCHAR(50) NOT NULL,
	Status VARCHAR(20) NOT null CHECK (
		Status IN ('Available', 'Borrowed', 'Reserved', 'Lost')
	),
	FOREIGN KEY (BookID) REFERENCES library_amina_db.Books (BookID) 
);

CREATE TABLE IF NOT EXISTS library_amina_db.Loans (
    LoanID SERIAL PRIMARY KEY,
    LoanDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    BorrowerID INT NOT NULL,
    CopyID INT NOT NULL,
    StaffID INT NOT NULL,
    FOREIGN KEY (BorrowerID) REFERENCES library_amina_db.Borrowers(BorrowerID),
    FOREIGN KEY (CopyID) REFERENCES library_amina_db.BookCopies(CopyID),
    FOREIGN KEY (StaffID) REFERENCES library_amina_db.LibraryStaff(StaffID)
);

CREATE TABLE IF NOT EXISTS library_amina_db.Reservations (
    ReservationID SERIAL PRIMARY KEY,
    BorrowerID INT NOT NULL,
    BookID INT NOT NULL,
    ReservationDate DATE NOT NULL,
    Status VARCHAR(20) DEFAULT 'Pending' CHECK (
        Status IN ('Pending', 'Completed', 'Cancelled')
    ),
    FOREIGN KEY (BorrowerID) REFERENCES library_amina_db.Borrowers(BorrowerID),
    FOREIGN KEY (BookID) REFERENCES library_amina_db.Books(BookID)
);

CREATE TABLE IF NOT EXISTS library_amina_db.Fines (
    FinesID SERIAL PRIMARY KEY,
    LoanID INT,
    FinePrice DECIMAL(10,2) CHECK (FinePrice >= 0),
    FineDate DATE,
    PayDue DATE,
    FOREIGN KEY (LoanID) REFERENCES library_amina_db.Loans(LoanID)
);

CREATE TABLE IF NOT EXISTS library_amina_db.BookGenre (
    BookID INT,
    GenresID INT,
    PRIMARY KEY (BookID, GenreID),
    FOREIGN KEY (BookID) REFERENCES library_amina_db.Books(BookID),
    FOREIGN KEY (GenreID) REFERENCES library_amina_db.Genres(GenresID)
);

CREATE TABLE IF NOT EXISTS library_amina_db.BookAuthors (
    BookID INT,
    AuthorsID INT,
    PRIMARY KEY (BookID, AuthorID),
    FOREIGN KEY (BookID) REFERENCES library_amina_db.Books(BookID),
    FOREIGN KEY (AuthorsID) REFERENCES library_amina_db.Authors(AuthorID)
);


ALTER TABLE Loans DROP CONSTRAINT IF EXISTS check_due_date;
ALTER TABLE Loans ADD CONSTRAINT check_due_date 
CHECK (DueDate > LoanDate);

ALTER TABLE Loans DROP CONSTRAINT IF EXISTS check_return_date;
ALTER TABLE Loans ADD CONSTRAINT check_return_date 
CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate);

ALTER TABLE Fines 
ALTER COLUMN FineDate SET DEFAULT CURRENT_DATE;

ALTER TABLE LibraryStaff DROP CONSTRAINT IF EXISTS check_job;
ALTER TABLE LibraryStaff ADD CONSTRAINT check_job 
CHECK (Job IN ('Librarian', 'Manager', 'Assistant'));

ALTER TABLE Borrowers DROP CONSTRAINT IF EXISTS check_email;
ALTER TABLE Borrowers ADD CONSTRAINT check_email 
CHECK (Email LIKE '%@%.%');

TRUNCATE TABLE 
    BookAuthors, BookGenre, Fines, Reservations, Loans,
    BookCopies, Borrowers, LibraryStaff, Authors, Books, Genres
CASCADE;


INSERT INTO library_amina_db.Genres (GenresName) VALUES
('Fiction'), ('Science'), ('History');

INSERT INTO library_amina_db.Authors (FirstName, LastName) VALUES
('George', 'Orwell'),
('Stephen', 'Hawking'),
('Yuval', 'Harari');

INSERT INTO library_amina_db.Books (BookName, BooksPublicationYear, ISBN) VALUES
('1984', 1949, '1234567890123'),
('Brief History of Time', 1988, '1234567890124'),
('Sapiens', 2011, '1234567890125');

INSERT INTO library_amina_db.Borrowers (FirstName, LastName, Email, Phone) VALUES
('Amina', 'Asan', 'amina@mail.com', '87788035847'),
('Ali', 'Khan', 'ali@mail.com', '870000000007'),
('Dana', 'Nur', 'dana@mail.com', '87000000003');

INSERT INTO library_amina_db.LibraryStaff 
(FirstName, LastName, Birthdate, Job, Phone, Email, Address, EmploymentDate)
VALUES
('John', 'Smith', '1990-01-01', 'Librarian', '87000000011', 'john@mail.com', 'Street 1', CURRENT_DATE),
('Anna', 'Lee', '1985-05-05', 'Manager', '87000000012', 'anna@mail.com', 'Street 2', CURRENT_DATE),
('Mark', 'Brown', '1992-03-03', 'Assistant', '87000000013', 'mark@mail.com', 'Street 3', CURRENT_DATE);


INSERT INTO library_amina_db.BookCopies (BookID, Barcode, Shelf, Status)
VALUES
((SELECT BookID FROM Books WHERE BookName='1984'), 'BC1', 'A1', 'Available'),
((SELECT BookID FROM Books WHERE BookName='Sapiens'), 'BC2', 'B1', 'Borrowed'),
((SELECT BookID FROM Books WHERE BookName='1984'), 'BC3', 'A2', 'Available');


INSERT INTO library_amina_db.Loans 
(LoanDate, DueDate, BorrowerID, CopyID, StaffID)
VALUES
(CURRENT_DATE, '2026-05-01',
 (SELECT BorrowerID FROM Borrowers WHERE FirstName='Amina'),
 (SELECT CopyID FROM BookCopies WHERE Barcode='BC2'),
 (SELECT StaffID FROM LibraryStaff LIMIT 1));

INSERT INTO library_amina_db.Reservations (BorrowerID, BookID, ReservationDate)
VALUES
((SELECT BorrowerID FROM library_amina_db.Borrowers WHERE FirstName='Ali'),
 (SELECT BookID FROM library_amina_db.Books WHERE BookName='1984'),
 CURRENT_DATE);

INSERT INTO library_amina_db.Fines (LoanID, FinePrice, PayDue)
VALUES
((SELECT LoanID FROM Loans LIMIT 1), 500.00, '2026-05-10');

INSERT INTO library_amina_db.BookGenre VALUES
((SELECT BookID FROM Books WHERE BookName='1984'),
 (SELECT GenresID FROM Genres WHERE GenresName='Fiction'));

INSERT INTO library_amina_db.BookAuthors VALUES
((SELECT BookID FROM library_amina_db.Books WHERE BookName='1984'),
 (SELECT AuthorsID FROM library_amina_db.Authors WHERE LastName='Orwell'));