create database LibraryManagment
use LibraryManagment
----Bảng catogory
CREATE TABLE Category (
    Catogory_ID INT IDENTITY(100,1),   -- ID là khóa chính và tự tăng
    Catogory_Name NVARCHAR(255) NOT NULL          -- Name là tên của danh mục và không được phép null
);
ALTER TABLE Category
ADD CONSTRAINT PK_Category_ID PRIMARY KEY (Catogory_ID);
----Bảng catogory

---Bảng author
CREATE TABLE Author (
    Author_ID INT IDENTITY(100,1),   -- ID_author là khóa chính và tự tăng
    Author_Name NVARCHAR(255) NOT NULL,   -- Name_author là tên của tác giả và không được phép NULL
	DoB DATE NOT NULL
);
ALTER TABLE Author
ADD CONSTRAINT PK_Author_ID PRIMARY KEY (Author_ID);
---Bảng author

-- Bảng publisher
CREATE TABLE Publisher (
    Publisher_ID INT IDENTITY(100,1),        -- ID là khóa chính và tự động tăng
    Publisher_Name NVARCHAR(255) NOT NULL,  -- Name là tên của nhà xuất bản, không được phép NULL
    Address NVARCHAR(500) NOT NULL -- Address là địa chỉ của nhà xuất bản, không được phép NULL
);
ALTER TABLE Publisher
ADD CONSTRAINT PK_Publisher_ID PRIMARY KEY (Publisher_ID);
-- Bảng publisher

--Bảng book
CREATE TABLE Book (
    Book_ID INT IDENTITY(100,1),        -- ID là khóa chính và tự động tăng
    Title NVARCHAR(255) NOT NULL, -- Title là tiêu đề của sách, không được phép NULL
    Category_ID INT,              -- Category_ID là ID của danh mục, kiểu INT
    Author_ID INT,                -- Author_ID là ID của tác giả, kiểu INT
	Price DECIMAL(18,2) NOT NULL
);
ALTER TABLE Book
ADD CONSTRAINT PK_Book_ID PRIMARY KEY (Book_ID);
ALTER TABLE Book
ADD CONSTRAINT FK_Book_Category FOREIGN KEY (Category_ID) REFERENCES Category(Catogory_ID);
ALTER TABLE Book
ADD CONSTRAINT FK_Book_Author FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID);
--Bảng book

-- Bảng BookCopy
CREATE TABLE BookCopy (
    BookCopy_ID INT IDENTITY(100,1),        -- bookcopy_id là khóa chính và tự động tăng
    Book_ID INT,                           -- book_id là ID của sách, kiểu INT
    Year_publish INT,                      -- year_publish là năm xuất bản, kiểu INT
    Publisher_ID INT,                      -- publisher_id là ID của nhà xuất bản, kiểu INT
);
ALTER TABLE BookCopy
ADD CONSTRAINT PK_BookCopy_ID PRIMARY KEY (BookCopy_ID);
ALTER TABLE BookCopy
ADD CONSTRAINT FK_BookCopy_Book FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID);
ALTER TABLE BookCopy
ADD CONSTRAINT FK_BookCopy_Publisher FOREIGN KEY (Publisher_ID) REFERENCES Publisher(Publisher_ID);
-- Bảng BookCopy

-- Bảng Reader
CREATE TABLE Reader (
    Reader_ID INT IDENTITY(100,1),        -- Reader_ID là khóa chính và tự động tăng
    Name NVARCHAR(255) NOT NULL,  -- Reader_Name là tên của bạn đọc, không được phép NULL
    Email NVARCHAR(255) NOT NULL,        -- Email là email của bạn đọc, không được phép NULL
    Phone NVARCHAR(20),                  -- Phone là số điện thoại của bạn đọc, có thể NULL nếu không có
    Total_Book_Loan INT DEFAULT 0,       -- Total_Book_Loan là tổng số sách đã mượn, mặc định là 0
);
alter table Reader
add  CONSTRAINT PK_Reader_ID PRIMARY KEY (Reader_ID) 
-- Bảng Reader

--Bảng Loan
CREATE TABLE Loan (
    Loan_ID INT IDENTITY(100,1),            -- Loan_ID là khóa chính và tự động tăng
    Checkoutday DATE NOT NULL,             -- Checkoutday là ngày mượn sách, không được phép NULL
    Returnday DATE NOT NULL,               -- Returnday là ngày trả sách, không được phép NULL
    Reader_ID INT,                         -- Reader_ID là ID của bạn đọc (sử dụng để tham chiếu tới bảng Reader)
);
ALTER TABLE Loan
ADD CONSTRAINT PK_Loan_ID PRIMARY KEY (Loan_ID);
ALTER TABLE Loan
ADD CONSTRAINT FK_Loan_Reader FOREIGN KEY (Reader_ID) REFERENCES Reader(Reader_ID);

--Bảng Loan
CREATE TABLE LoanDetail (
    Detail_ID INT IDENTITY(100,1),          -- Detail_ID là khóa chính và tự động tăng
    Loan_ID INT,                          -- Loan_ID là ID của phiếu mượn, tham chiếu đến bảng Loan
    BookCopy_ID INT,                      -- BookCopy_ID là ID của bản sao sách, tham chiếu đến bảng BookCopy
    Returnday DATE NOT NULL,              -- Returnday là ngày trả sách, không được phép NULL
    Deposit DECIMAL(18,2) NOT NULL,       -- Deposit là tiền cọc, kiểu DECIMAL (18,2)
    TotalAmount DECIMAL(18,2) NOT NULL,   -- TotalAmount là tổng tiền thanh toán, kiểu DECIMAL (18,2)
);
-- Thêm khóa chính cho bảng LoanDetail
ALTER TABLE LoanDetail
ADD CONSTRAINT PK_LoanDetail_Detail_ID PRIMARY KEY (Detail_ID);
-- Thêm khóa ngoại cho Loan_ID, tham chiếu đến bảng Loan
ALTER TABLE LoanDetail
ADD CONSTRAINT FK_LoanDetail_Loan FOREIGN KEY (Loan_ID) REFERENCES Loan(Loan_ID);
-- Thêm khóa ngoại cho BookCopy_ID, tham chiếu đến bảng BookCopy
ALTER TABLE LoanDetail
ADD CONSTRAINT FK_LoanDetail_BookCopy FOREIGN KEY (BookCopy_ID) REFERENCES BookCopy(BookCopy_ID);
--trigger tính giá cọc
CREATE TRIGGER trg_CalculateDeposit
ON LoanDetail
AFTER INSERT
AS
BEGIN
    UPDATE LoanDetail
    SET Deposit = Book.Price * 0.3
    FROM LoanDetail
    INNER JOIN BookCopy ON LoanDetail.BookCopy_ID = BookCopy.BookCopy_ID
    INNER JOIN Book ON BookCopy.Book_ID = Book.Book_ID
    WHERE LoanDetail.Detail_ID IN (SELECT Detail_ID FROM Inserted);
END;
---trigger tính thành tiền 
CREATE TRIGGER trg_CalculateDepositAndTotalAmount
ON LoanDetail
AFTER INSERT
AS
BEGIN
    UPDATE LoanDetail
    SET 
        Deposit = Book.Price * 0.3,
        TotalAmount = (Book.Price * 0.3) + Book.Price
    FROM LoanDetail
    INNER JOIN BookCopy ON LoanDetail.BookCopy_ID = BookCopy.BookCopy_ID
    INNER JOIN Book ON BookCopy.Book_ID = Book.Book_ID
    WHERE LoanDetail.Detail_ID IN (SELECT Detail_ID FROM Inserted);
END;
--Bảng Loan

---Bảng Fine
CREATE TABLE Fine (
    Fine_ID INT IDENTITY(1,1) PRIMARY KEY,  -- Fine_ID là khóa chính và tự động tăng
    Detail_ID INT NOT NULL,                 -- Detail_ID tham chiếu đến LoanDetail
    Reader_ID INT NOT NULL,                 -- Reader_ID tham chiếu đến Reader
    Library_fine DECIMAL(18,2) NOT NULL,    -- library_fine là khoản phạt, kiểu DECIMAL (18,2)
    Reason NVARCHAR(255) NOT NULL           -- reason là lý do phạt, kiểu NVARCHAR
);
-- Thiết lập các khóa ngoại
ALTER TABLE Fine
ADD CONSTRAINT FK_Fine_LoanDetail FOREIGN KEY (Detail_ID) REFERENCES LoanDetail(Detail_ID);
ALTER TABLE Fine
ADD CONSTRAINT FK_Fine_Reader FOREIGN KEY (Reader_ID) REFERENCES Reader(Reader_ID);
