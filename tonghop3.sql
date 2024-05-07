create database if not exists quanlysach;
use quanlysach;

create table if not exists category
(
    id     int auto_increment primary key,
    name   varchar(100) not null,
    status tinyint default 1,
    check (status in (0, 1))
);


create table if not exists author
(
    id        int auto_increment primary key,
    name      varchar(100) not null,
    unique (name),
    totalBook int default 0
);

create table if not exists book
(
    id         int auto_increment primary key,
    name       varchar(150) not null,
    status     tinyint default 1,
    check ( status in (0, 1)),
    price      float        not null,
    check ( price >= 100000),
    createDate date    default (curdate()),
    categoryId int          not null,
    foreign key (categoryId) references category (id),
    authorId   int          not null,
    foreign key (authorId) references author (id)
);



create table if not exists customer
(
    id          int auto_increment primary key,
    name        varchar(150) not null,
    email       varchar(150) not null,
    check (email like ('%@gmail.com') or
           email like ('%@facebook.com') or
           email like ('%@bachkhoa-aptech.edu.vn')
        ),
    unique (email),
    phone       varchar(50)  not null,
    unique (phone),
    address     varchar(255),
    createdDate date default (curdate()),
    gender      tinyint      not null,
    check (gender in (0, 1, 2)),
    birthday    date         not null

);
create table if not exists ticket
(
    id         int auto_increment primary key,
    customerId int not null,
    foreign key (customerId) references customer (id),
    status     tinyint  default 1,
    check ( status in (0, 1, 2, 3) ),
    ticketDate datetime default (curdate())
);


create table if not exists ticketDetail
(
    ticketId     int   not null,
    foreign key (ticketId) references ticket (id),
    bookId       int   not null,
    foreign key (bookId) references book (id),
    quantity     int   not null,
    check ( quantity > 0 ),
    depositPrice float not null,
    rentCost     float not null


);
delimiter //

create trigger before_ticketdetail_insert
    before insert
    on TicketDetail
    for each row
begin
    declare book_price float;

    -- Lấy giá của sách tương ứng
    select Price into book_price from Book where Book.Id = NEW.BookId;

    -- Tính toán giá trị cho DepositPrice và RentCost
    set NEW.depositPrice = book_price;
    set NEW.RentCost = 0.1 * book_price;
end;

delimiter //

insert into category(name)
values ('thieu nhi'),
       ('trinh tham'),
       ('hai');

insert into author(name, totalbook)
values ('kim dong', 1),
       ('to hoai', 2),
       ('rowling', 1);

insert into book(name, status, price, createDate, categoryId, authorId)
values ('7 vien ngoc rong', 0, 150000, now(), 1, 1);
insert into book(name, status, price, createDate, categoryId, authorId)
values ('6 vien ngoc rong', 0, 200000, now(), 2, 2);
insert into book(name, status, price, createDate, categoryId, authorId)
values ('5 vien ngoc rong', 0, 300000, now(), 3, 3);
insert into book(name, status, price, createDate, categoryId, authorId)
values ('4 vien ngoc rong', 0, 500000, now(), 2, 1);

insert into customer(name, email, phone, address, createdDate, gender, birthday)
values ('hung', 'hung@gmail.com', 0912999669, 'hn', curdate(), 0, '1996-01-22');

insert into customer(name, email, phone, address, createdDate, gender, birthday)
values ('a', 'a@facebook.com', 0912999668, 'hn', curdate(), 0, '1996-01-23');

insert into customer(name, email, phone, address, createdDate, gender, birthday)
values ('b', 'b@bachkhoa-aptech.edu.vn', 0912999666, 'hn', curdate(), 0, '1996-01-24');

insert into customer(name, email, phone, address, createdDate, gender, birthday)
values ('c', 'c@bachkhoa-aptech.edu.vn', 0912999696, 'hn', curdate(), 0, '1996-01-25');

insert into Ticket (CustomerId, Status, TicketDate)
values (1, 1, NOW());
insert into Ticket (CustomerId, Status, TicketDate)
values (2, 1, NOW());
insert into Ticket (CustomerId, Status, TicketDate)
values (3, 1, NOW());
insert into Ticket (CustomerId, Status, TicketDate)
values (4, 1, NOW());

insert into TicketDetail (TicketId, BookId, Quantity)
values (1, 1, 2);
insert into TicketDetail (TicketId, BookId, Quantity)
values (2, 1, 1);
insert into TicketDetail (TicketId, BookId, Quantity)
values (3, 1, 1);
insert into TicketDetail (TicketId, BookId, Quantity)
values (4, 1, 1);
insert into TicketDetail (TicketId, BookId, Quantity)
values (2, 2, 3);
insert into TicketDetail (TicketId, BookId, Quantity)
values (3, 3, 4);

# 1. Lấy ra danh sách Book có sắp xếp giảm dần theo Price gồm các cột sau: Id, Name, 	Price, Status, CategoryName, AuthorName, CreatedDate

select b.Id, b.Name, Price, b.status, c.name CategoryName, a.name AuthorName, b.createDate CreatedDate
from book b
         join category c on c.id = b.categoryId
         join author a on a.id = b.authorId
order by b.price desc;


# 2. Lấy ra danh sách Category gồm: Id, Name, TotalProduct, Status (Trong đó cột Status nếu = 0, Ẩn, = 1 là Hiển thị )

select c.Id,
       c.Name,
       count(b.id)                                                               TotalProduct,
       case when c.status = 0 then 'Ẩn' when c.status = 1 then 'Hiển thị' end as Status
from category c
         join book b on c.id = b.categoryId
group by c.Id, c.Name, c.Status;

# 3. Truy vấn danh sách Customer gồm:
# Id, Name, Email, Phone, Address, CreatedDate, Gender, BirthDay,
# Age (Age là cột suy ra từ BirthDay, Gender nếu = 0 là Nam, 1 là Nữ,2 là khác )
select Id,
       Name,
       Email,
       Phone,
       Address,
       CreatedDate,
       case
           when gender = 0 then 'Nam'
           when gender = 1 then 'Nữ'
           when gender = 2 then 'khác'
           else ' giới tính k xác định' end as Gender,
       BirthDay,
       year(curdate()) - year(birthday)        Age
from customer;


# Truy vấn xóa Author chưa có sách nào

delete
from Author
where Id not in (select distinct AuthorId from Book);


# Cập nhật cột TotalBook trong bảng Author
update Author a
set TotalBook = (select count(*) from Book where AuthorId = a.Id);


# View v_getBookInfo để lấy ra danh sách các sách được mượn nhiều hơn 3 cuốn

create view v_getbookinfo as
select td.bookid     as id,
       b.name,
       SUM(quantity) as borrowcount
from ticketdetail td
         join
     book b on td.bookid = b.id
group by td.bookid, b.name
having borrowcount > 3;

# View v_getTicketList để hiển thị danh sách Ticket:

create view v_getticketlist as
select t.id,
       t.ticketdate,
       case t.status
           when 0 then 'chưa trả'
           when 1 then 'đã trả'
           when 2 then 'quá hạn'
           when 3 then 'đã hủy'
           else 'unknown'
           end          as status,
       c.name           as cusname,
       c.email,
       c.phone,
       sum(td.rentcost) as totalamount
from ticket t
         join
     customer c on t.customerid = c.id
         join
     ticketdetail td on t.id = td.ticketid
group by t.id, t.ticketdate, t.status, c.name, c.email, c.phone;

# Thủ tục addBookInfo để thêm mới thông tin sách:
delimiter //
create procedure addBookInfo(
    in bookName varchar(150),
    in bookStatus tinyint,
    in bookPrice float,
    in bookCreateDate date,
    in bookCategoryId int,
    in bookAuthorId int
)
begin
    insert Book (Name, Status, Price, CreateDate, CategoryId, AuthorId)
    values (bookName, bookStatus, bookPrice, bookCreateDate, bookCategoryId, bookAuthorId);
end;
delimiter //
call addBookInfo('conan', 1, 400000, now(), 2, 1);

# Thủ tục getTicketByCustomerId để hiển thị danh sách đơn hàng của khách hàng theo ID của khách hàng:
delimiter //
create procedure getTicketByCustomerId(
    in customerId int
)
begin
    select t.Id,
           t.TicketDate,
           case t.Status
               when 0 then 'Chưa trả'
               when 1 then 'Đã trả'
               when 2 then 'Quá hạn'
               when 3 then 'Đã hủy'
               else 'Unknown'
               end          as Status,
           SUM(td.RentCost) as TotalAmount
    from Ticket t
             join
         TicketDetail td on t.Id = td.TicketId
    where t.CustomerId = customerId
    group by t.Id, t.TicketDate, t.Status;
end;
delimiter //
call getTicketByCustomerId(1);

# Thủ tục getBookPaginate để lấy ra danh sách sản phẩm có phân trang:
delimiter //
create procedure getBookPaginate(
    in limitRows int,
    in page int
)
begin
    declare offsetRows int default 0;
    set offsetRows = (page - 1) * limitRows;

    select Id,
           Name,
           Price

    from Book
    limit offsetRows, limitRows;
end;
delimiter //
call getBookPaginate(3, 1);

# Trigger tr_Check_total_book_author để kiểm tra tổng số sách của tác giả trước khi thêm sách mới:

delimiter //
create trigger tr_check_total_book_author
    before insert
    on book
    for each row
begin
    declare authorBookCount int;

    -- Lấy tổng số sách của tác giả
    select count(*)
    into authorBookCount
    from book
    where AuthorId = new.AuthorId;

    -- Kiểm tra nếu tổng số sách của tác giả vượt quá 5
    if authorBookCount >= 5 then
        signal sqlstate '45000'
            set message_text = 'Tác giả này có số lượng sách đạt tới giới hạn 5 cuốn, vui lòng chọn tác giả khác';
    end if;
end;
delimiter //


# 2.Tạo trigger tr_Update_TotalBook khi thêm mới Book thì cập nhật cột TotalBook rong bảng Author = tổng của Book theo AuthorId
delimiter //
create trigger tr_update_total_book
    after insert
    on book
    for each row
begin
    declare authorBookCount int;

#  Lấy tổng số sách của tác giả
    select count(*)
    into authorBookCount
    from book
    where AuthorId = new.AuthorId;

    -- Cập nhật cột TotalBook trong bảng Author
    update author
    set TotalBook = authorBookCount
    where Id = new.AuthorId;
end;

delimiter //
