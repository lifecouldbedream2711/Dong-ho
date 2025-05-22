  
.model small
.stack 100h
.data 

     t0  DB "         /^\\/^\\                                  $"  ;ve con ran
     t1  DB "   _____| O|  O|   _                               $"  ;ve mat ran
     t2  DB "\\/     /~~    \\_/ \\                             $"  ;co the ran
     t3  DB " \\____|__________/  \\                            $"  ;co the ran
     t4  DB "        \\_______      \\                          $"  ;co the ran
     t5  DB "                `\\     \\                         $"  ;co the ran
     t6  DB "                  |     ||                         $"  ;co the ran
     t7  DB "                 /     //       ____               $"  ;co the ran
     t8  DB "                /     /\\      / _*_\              $"  ;co the ran
     t9  DB "               /      \\ \\   / /                  $"  ;co the ran
     t10 DB "              |        \\ \\ / /                   $"  ;co the ran
     t11 DB "               \\_______|_|_/_/                    $"  ;thong bao chao mung
     t12 DB "WELCOME TO SNAKE GAME!$"                               ;thong bao bat dau
     main1 DB "Press any key to start... $"                         ;tieu de
     hd1 db '       X    Snake game    O         $'                 ;huong dan
     hd2 db 'Huong dan cach di chuyen con ran X  $'
     ;change font in man hinh la terminal de hien mui ten
     hd4 db 24, ' w : di len tren      $'
     hd5 db 27, ' a : di sang trai     $'
     hd6 db 25, ' s : di xuong duoi    $'
     hd7 db 26, ' d : di sang phai     $'
     hd8 db 'Chu y:                                    $'             
     hd9 db 'Phim bam khong hop le se bi bo qua        $'             ;canh bao di sai
     hd10 db 'Con ran khong the di lui duoc            $'             ;khong the di nguoc
     hd11 db 'Con ran khong the di qua than chinh no   $'             ;con ran co the di xuyen qua co the
     hd12 db 'An ban ki phim gi de bat dau choi......  $'             ;thong bao chao mung
     kq1 db 'So diem ban da dat duoc: $'                              ;thong bao diem khi ket thuc
     kq2 db 'Chuc mung ban da chien thang tro choi$'                  ;thong bao chien thang
     tb_choi_lai db 'Ban co muon choi tiep khong? <y/n> $'            ;hoi choi lai
     end1 db '-------- PROJECT - SNAKE GAME -------$'
     end2 db '------------- GROUP 13 --------------$'                 ;nhom thuc hien
     end3 db '*********************************************$' 
     end4 db '        Thank you for playing! $'                       ;loi cam on
     diem1 db 'Score : $'                                             ;hien diem
     dong db 13, 10, '$'                                              ;xuong dong
     begin_row db 5                                                   ;hang rao nam ngang phia tren
     end_row db 20                                                    ;hang rao nam nganh phia duoi
     begin_column db 20                                               ;hang rao nam doc ben trai
     end_column db 60                                                 ;hang rao nam doc ben phai
     snake_x db 10                                                    ;vi tri bat dau cua con ran (10, 40)
     snake_y db 40                                                    
     toa_do_x db 15 dup(?)                                            ;mang luu toa do truc hoanh(x) cua con ran
     toa_do_y db 15 dup(?)                                            ;mang luu toa do truc tung(y) cua con ran
     app_x db ?                                                       ;vi tri cua tao
     app_y db ?
     len_snake db 0                                                   ;do dai hien tai cua ran
     score db 0                                                       ;diem nguoi choi
     score_max db 10                                                  ;diem toi da
     old_key db 'g'                                                   ;huong cu cua con ran
     border_row db 40 dup("#"), "$"                                   ;hang rao nam ngang

.code

;sinh ngau nhien 1 so c trong khoang tu a toi b (la so chan)
ngau_nhien macro a, b, c
    local be_hon_b, lon_hon_a           ;khai bao nhan 
    
    pusha           ;luu het gia tri cac thanh ghi vao trong stack 
    mov ah, 0       ;chuan bi lay thoi gian he thong nhat bang ngat 1ah/0h
    int 1ah         ;goi ngat 1ah - tra ve thoi gian he thong trong cx:dx 
    ;(co the hieu la lay mot gia tri ngau nhien luu vao dl)
    mov al, dl      ;luu gia tri vua lay duoc vao al
    
    mov bl, b       ;luu gia tri gioi han cua hang rao (hang rao nam ngang phia duoi hoac nam doc ben phai)
    div bl          ;lay al chia bl, lay phan du de dam bao so lay duoc luon be hon b
    mov al, ah      ;luu so du day vao al
    
    mov ah, 0       ;xoa ah de chuan bi nhan
    mov bl, 2       ;luu bl = 2
    mul bl          ;phep nhan al voi 2 de dam bao so lay duoc(toa do qua tao) luon chan(de lam tang toc do con ran)
    
    cmp al, b       ;neu al van con be hon b thi thoa man
    jl be_hon_b     ;nhay luon de kiem tra gia tri ngau nhien co lon hon gioi han hang rao bien nho
    sub al, b       ;neu so sau khi nhan vuot qua b thi phai tru di b

be_hon_b:           ;nhan khi gia tri ngau nhien da nho hon gioi han hang rao bien lon 
    cmp al, a       ;a chinh la gia tri goi han, al luc nay van la gia tri ngau nhien sau khi nhan 2
    jg lon_hon_a    ;neu al > a -> thoa man
    add al, a       ;neu al < a -> cong them a vao al
    add al, 2       ;neu sao khi cong al = a -> al += 2 (tranh viec qua tao sinh ra trung voi hang rao) 
                    
lon_hon_a:
    mov c, al       ;luu gia tri ngau nhien vao bien c ban dau
    popa            ;lay lan luot gia tri da luu truoc trong stack va luu lai vao thanh ghi
ngau_nhien endm

;cap nhat toa do moi khi con ran di chuyen;
toa_do_moi macro a, b 
    local lap, ket      ;tao ham cuc bo (ham co tac dung trong ham toa_do_moi)
    
    pusha               ;day het gia tri da luu trong thanh ghi vao trong stack
    mov ch, 0           ;reset thanh ghi cx
    mov cl, len_snake   ;luu lai chieu dai con ran vao thanh ghi cx
    lea di, a           ;dua thanh ghi dia chi di toi vi tri dau tien (di = dia chi phan tu dau danh sach)
    lea si, a
    inc si              ;dua thanh ghi dia chi si toi vi tri thu hai  (si = dia chi phan tu ke tiep)
    
    lap: 
        dec cx          ;giam so lan lap
        cmp cx, 0
        jng ket         ;neu het so lan duyet thi nhay den ham ket
        
        mov dx, [si]    ;luu tam gia tri tiep theo vao thanh dx
        mov [di], dx    ;gan gia tri ke tiep vao vi tri truoc do
        
        inc si          ;xet toi gia tri tiep theo (tang chi so si)
        inc di          ;tang chi so di
        jmp lap         ;lap tiep
    
    ket:
    mov dl, b           ;luu gia tri moi vao thanh dl
    mov [di], dl        ;luu gia tri moi vao cuoi danh sach
    popa                ;lay het gia tri da day trong stack va gan lan luot vao thanh ghi
toa_do_moi endm 

;them toa do moi khi con ran an tao
them_toa_do_snake macro a, b
    pusha               ;day het gia tri trong thanh ghi vao trong stack  
    mov ch, 0           ;reset thanh ghi cx
    mov cl, len_snake   ;luu gia tri chieu dai con ran vao thanh cx
    
    lea di, toa_do_x    ;luu dia chi phan tu dau tien cua danh sach toa_do_ x (duoi con ran)
    add di, cx          ;tro den phan tu cuoi danh sach (dau con ran)
    mov dl, a
    mov [di], dl        ;luu gia tri x moi them vao cuoi danh sach
    
    lea di, toa_do_y    ;luu dia chi phan tu dau tien cua danh sach toa_do_ y (duoi con ran)
    add di, cx          ;tro den phan tu cuoi danh sach (dau con ran
    mov dl, b
    mov [di], dl        ;luu gia tri x moi them vao cuoi danh sach
    
    inc cl              ;tang chieu dai con ran
    mov len_snake, cl   ;cap nhat chieu dai con ran
    popa                ;tra lai cac gia tri da luu trong stack tro lai thanh ghi
them_toa_do_snake endm
 
di_chuyen_con_tro macro a, b 
    pusha               ;luu toan bo thanh ghi de tranh anh huong chuong trinh chinh
    mov ah, 2           ;chon che do dat vi tri con tro ham ngat 10h - di chuyen con tro
    mov bh, 0           ;so trang man hinh = 0
    mov dh, a           ;vi tri hang (dh = hang)
    mov dl, b           ;vi tri cot  (dl = cot)
    int 10h             ;goi ham ngat 10h de di chuyen con tro
    popa                ;khoi phuc thanh ghi
di_chuyen_con_tro endm 
 
gan_toa_do macro a, b, c
    mov dh, a                   ;luu vi tri hang vao thanh dh (dh = chi so hang)
    mov dl, b                   ;luu vi tri cot vao thanh dl  (dl = chi so cot)
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri a, b    
    
    pusha                       ;luu toan bo thanh ghi de tranh anh huong chuong trinh chinh
    mov ah, 2                   ;chuc nang in 1 ki tu ham ngat 21h
    mov dl, c                   ;luu ki tu c vao thanh dl
    int 21h                     ;thuc hien lenh in ki tu
    popa                        ;khoi phuc thanh ghi  
gan_toa_do endm

in_thong_bao macro a
    pusha               ;luu toan bo thanh ghi de tranh anh huong chuong trinh chinh
    mov ah, 9           ;che do in 1 chuoi ki tu ham ngat 21h
    lea dx, a           ;dx = dia chi chuoi can in
    int 21h             ;thuc hien in chuoi
    popa                ;khoi phuc thanh ghi
in_thong_bao endm

main proc
    mov ax, @data    ;di chuyen dia chi du lieu vao thanh ghi ax               
    mov ds, ax       ;cap nhat thanh ghi ds voi gia tri trong ax
    mov es, ax       ;cap nhat thanh ghi es voi gia tri trong ax
    ;thiet lap che do man hinh hien thi
    mov ah, 0        ;tao man hinh moi ham ngat 10h
    mov al, 3        ;chon kich thuoc man hinh 80x25
    int 10h          ;thuc hien tao man hinh kich thuoc 80x25    
    
    ;in con ran ra man hinh bang cach di chuyen con tro rui in ca xau ki tu ra man hinh
        di_chuyen_con_tro 5, 22         ;di chuyen con tro toi vi tri 5, 22 
    in_thong_bao t0                     ;in dong t0
        di_chuyen_con_tro 6, 22         ;di chuyen con tro toi vi tri 6, 22
    in_thong_bao t1                     ;in dong t1
        di_chuyen_con_tro 7, 22         ;di chuyen con tro toi vi tri 7, 22
    in_thong_bao t2                     ;in dong t2
        di_chuyen_con_tro 8, 22         ;di chuyen con tro toi vi tri 8, 22
    in_thong_bao t3                     ;in dong t3
        di_chuyen_con_tro 9, 22         ;di chuyen con tro toi vi tri 9, 22
    in_thong_bao t4                     ;in dong t4
        di_chuyen_con_tro 10, 22        ;di chuyen con tro toi vi tri 10, 22
    in_thong_bao t5                     ;in dong t5
        di_chuyen_con_tro 11, 22        ;di chuyen con tro toi vi tri 11, 22
    in_thong_bao t6                     ;in dong t6
        di_chuyen_con_tro 12, 22        ;di chuyen con tro toi vi tri 12, 22
    in_thong_bao t7                     ;in dong t7
        di_chuyen_con_tro 13, 22        ;di chuyen con tro toi vi tri 13, 22
    in_thong_bao t8                     ;in dong t8
        di_chuyen_con_tro 14, 22        ;di chuyen con tro toi vi tri 14, 22
    in_thong_bao t9                     ;in dong t9
        di_chuyen_con_tro 15, 22        ;di chuyen con tro toi vi tri 15, 22
    in_thong_bao t10                    ;in dong t10
        di_chuyen_con_tro 16, 22        ;di chuyen con tro toi vi tri 16, 22
    in_thong_bao t11                    ;in dong t11
        di_chuyen_con_tro 18, 27        ;di chuyen con tro toi vi tri 18, 27
    in_thong_bao t12                    ;in dong t12
        di_chuyen_con_tro 20, 26        ;di chuyen con tro toi vi tri 20, 26
    in_thong_bao main1                  ;in thong bao main1
    
    mov ah, 1                ;che do nhap 1 ki tu tu ban phim
    int 21h                  ;goi ham ngat 21h de lay 1 ki tu vua nhap (nhap 1 ki tu bat ki de sang phan tiep theo)
    
    call huongdan            ;hien thi thong bao huong dan choi
    mov dx, 0                ;luu thanh dh, dl bang 0
    di_chuyen_con_tro dh, dl ;dau con tro
    
    mov ah, 1                ;che do nhap 1 ki tu tu ban phim
    int 21h                  ;goi ham ngat 21h de lay 1 ki tu vua nhap (nhap 1 ki tu bat ki de sang phan tiep theo) 

choi_game:                   ;bat dau choi game
    call choi                ;goi ham tro choi snake
   
main endp

choi proc
    
    ;reset lai man hinh hien thi de bat dau tro choi  
    call xoa_man_hinh                   ;xoa het ki tu xuat hien tren man hinh
   
    call border                         ;in ra hang rao
    call hiendiem                       ;hien thi diem ban dau (diem ban dau se duoc mac dinh bang 0) 
    them_toa_do_snake snake_x, snake_y  ;them toa do ran ban dau  
    call in_ran                         ;in hinh con ran ban dau
    ;khoi tao 10 qua tao ban dau
    mov cx, 10      ;so qua tao ban dau luu vao thanh ghi cx = 10
    sinh_tao_ban_dau:
         call sinh_apple        ;goi chuong trinh con sinh ngau nhien 1 qua tao
    loop sinh_tao_ban_dau
   
    game_loop:
        mov dx, 0                       ;luu thanh dh, dl bang 0 
        di_chuyen_con_tro dh, dl        ;giau con tro
        
        ;xu li phim nhap 
        mov ah, 1                       ;chon che do lay phim tu buffer ham ngat 16h/01h
        int 16h                         ;thuc hien lay 1 phim tu buffer
        jz no_key_input                 ;nhay toi nhan neu khong co phim nhap
        mov ah, 0                       ;chon che do nhap phim ham ngat 16h
        int 16h                         ;lenh nhap ca ki tu lan phim chuc nang
        jmp xong                        ;nay toi nhan xong
        no_key_input:                   ;nhan khi khong co phim nhap
        mov al, old_key                 ;luu lai phim nhap cu xa di chuyen tiep con ran
        xong:                           ;nhan khi xu li xong input
        
        mov bl, old_key                 ;luu lai phim dieu khien con ran cu vao thanh bl
        ;phim dieu khien con ran len tren
        cmp al, 'w'                     ;so sanh ki tu vua nhap voi chu cai 'w'
        je len_tren                     ;neu bang thi nhay den ham xu li con ran di len
        cmp ah, 72                      ;so sanh voi ma code mui ten huong len voi ki tu vua nhap
        je len_tren                     ;neu bang thi nhay den ham xu li con ran di len
        
        ;phim dieu khien con ran xuong duoi
        cmp al, 's'                     ;so sanh ki tu vua nhap voi chu cai 's'
        je xuong_duoi                   ;neu bang thi nhay den ham xu li con ran di xuong
        cmp ah, 80                      ;so sanh voi ma code mui ten huong xuong voi ki tu vua nhap
        je xuong_duoi                   ;neu bang thi nhay den ham xu li con ran di xuong
        
        ;phim dieu khien con ran sang trai
        cmp al, 'a'                     ;so sanh ki tu vua nhap voi chu cai 'a'
        je sang_trai                    ;neu bang thi nhay den ham xu li con ran di sang trai
        cmp ah, 75                      ;so sanh voi ma code mui ten huong sang trai voi ki tu vua nhap
        je sang_trai                    ;neu bang thi nhay den ham xu li con ran di sang trai
        
        ;phim dieu khien con ran sang phai
        cmp al, 'd'                     ;so sanh ki tu vua nhap voi chu cai 'd'
        je sang_phai                    ;neu bang thi nhay den ham xu li con ran di sang phai
        cmp ah, 77                      ;so sanh voi ma code mui ten huong sang phai voi ki tu vua nhap
        je sang_phai                    ;neu bang thi nhay den ham xu li con ran di sang phai
        
        jmp game_loop       ;neu nham ki tu khong hop le thi chuong trinh se khong lam gi va quay lai nhap ki tu khac
    
        ;cac huong di chuyen cua con ran    
len_tren:
    cmp bl, 's'                     ;neu huong cu la di xuong (nguoc huong hien tai) thi chuong trinh khong chap nhan
    je game_loop                    ;quay lai nhap ki tu khac
    mov old_key, 'w'                ;neu hop le -> huong hien tai tro thanh huong cu moi 
    dec snake_x                     ;giam toa_do_x con ran di 1 (vi ran dang di len)
    jmp check                       ;nhay den ham kiem tra

xuong_duoi:
    cmp bl, 'w'                     ;neu huong cu la di xuong (nguoc huong hien tai) thi chuong trinh khong chap nhan
    je game_loop                    ;quay lai nhap ki tu khac
    mov old_key, 's'                ;neu hop le -> huong hien tai tro thanh huong cu moi
    inc snake_x                     ;tang toa_do_x con ran len 1 (vi con ran di xuong)
    jmp check                       ;nhay den ham kiem tra

sang_trai:
    cmp bl, 'd'                     ;neu huong cu la di xuong (nguoc huong hien tai) thi chuong trinh khong chap nhan
    je game_loop                    ;quay lai nhap ki tu khac
    mov old_key, 'a'                ;neu hop le -> huong hien tai tro thanh huong cu moi
    sub snake_y, 2                  ;tang toa_do_y con ran len 2 (vi con ran sang phai)
    jmp check                       ;nhay den ham kiem tra

sang_phai:                          
    cmp bl, 'a'                     ;neu huong cu la di xuong (nguoc huong hien tai) thi chuong trinh khong chap nhan
    je game_loop                    ;quay lai nhap ki tu khac
    mov old_key, 'd'                ;neu hop le -> huong hien tai tro thanh huong cu moi
    add snake_y, 2                  ;giam toa_do_y con ran di 2 (vi con ran sang trai)
    jmp check                       ;nhay den ham kiem tra
            
    check:                          ;kiem tra con ran co cham hang rao, dam than chinh no hay an tao khong 
        
        di_chuyen_con_tro snake_x, snake_y      ;di chuyen con tro toi vi tri dau con ran moi
        mov ah, 8                       ;chon che do doc ki tu tai vi tri con tro ham ngat 10h/08h
        mov bh, 0                       ;so trang man hinh
        int 10h                         ;thuc hien lenh doc ki tu tai vi tri con tro   
        
        ;kiem tra con ran co dam hang rao khong
        cmp al, '#'                     ;so sanh ki tu voi hang rao '#'
        je game_over                    ;neu co thi thua luon  
        
        ;kiem tra con ran co dam vao chinh khuc cua minh khong
        cmp al, '.'                     ;so sanh ki tu voi ki tu duoi cua con ran
        je game_over                    ;neu co thi thua luon
        cmp al, 'x'                     ;so sanh ki tu voi ki tu than cua con ran
        je game_over                    ;nhay toi nhan thua cuoc
       
        ;con ran co an qua tao khong
        cmp al, 'O'                 ;so sanh ki tu voi ki tu qua tao
        je an                       ;neu khong thi chua an duoc qua tao
        
        ;toi day xac dinh rang con ran khong dam hang rao, khong di qua than, khong an tao
        jmp lap_tiep                   ;nhay toi nhan lap_tiep va tiep tuc chuong trinh
    
    an: 
        ;tang so diem dat duoc
        mov dl, score                   ;gan diem truoc khi an tao vao dl
        inc dl                          ;tang diem hien len
        mov score, dl                   ;cap nhat diem hien 
        cmp dl, score_max               ;kiem tra diem hien tai da bang diem toi da chua
        je call ket_thuc                ;neu bang thi nhay den ham ket_thuc (de ket thuc man choi)
        call hiendiem                   ;hien thi so diem hien tai
        ;tang chieu dai con ran
        them_toa_do_snake snake_x, snake_y      ;them toa do qua tao vua an vua mang luu phan than con ran
        call in_ran                             ;in hinh con ran sau khi them 1 khuc
        call sinh_apple                 ;neu khong bang thi sinh ra qua tao moi
        call sinh_apple                 ;thuc hien sinh 2 qua tao moi
        jmp game_loop                   ;tiep tuc tro choi
    
    lap_tiep:
        ;cap nhat lai toa do moi cua con ran
        lea di, toa_do_x                ;gan dia chi phan tu dau tien cua toa_do_x con ran vao di (duoi con ran)
        lea si, toa_do_y                ;gan dia chi phan tu dau tien cua toa_do_y con ran vao si (duoi con ran)

        gan_toa_do [di], [si], ' '      ;xoa khuc duoi bang ki tu khoang trang
        toa_do_moi toa_do_x, snake_x    ;cap nhat toa do x
        toa_do_moi toa_do_y, snake_y    ;cap nhat toa do y
        
        call in_ran                     ;in ra hinh con ran moi
        jmp game_loop                   ;tiep tuc tro choi
    
    game_over: 
        call ket_thuc               ;neu khong vuot qua duoc ham check(thua cuoc) -> nhay den ham ket_thuc de xu li
choi endp

;ham sinh 1 qua tao moi
sinh_apple proc 
    ngau_nhien begin_row, end_row, app_x            ;tao toa_do_x cua qua tao
    ngau_nhien begin_column, end_column, app_y      ;tao toa_do_y cua qua tao
    gan_toa_do app_x, app_y, 'O'                    ;in ra qua tao moi
    ret
sinh_apple endp

;in hinh con ran
in_ran proc                                
    lea di, toa_do_x                       ;gan dia chi phan tu dau tien cua toa_do_x con ran vao di (duoi con ran)
    lea si, toa_do_y                       ;gan dia chi phan tu dau tien cua toa_do_y con ran vao si (duoi con ran)
    
    mov ch, 0                              ;reset lai thanh ghi ch
    mov cl, len_snake                      ;luu chieu dai con ran vao thanh ghi cl
    cmp cx, 1                              ;kiem tra chieu dai = 1 thi chi in dau con ran
    jng ket                                ;thuc hien in dau con ran
    gan_toa_do [di], [si], '.'             ;in duoi con ran
    
    inc di                                 ;tang chi so di (de in phan than con ran)
    inc si                                 ;tang chi so si (de in phan than con ran)
    lapin:
        dec cx                             ;giam so than ran can in (vi da in cai duoi)
        cmp cx, 1                          ;kiem tra in het than con ran chua
        jng ket                            ;in het than con ran thi ket thuc va in dau con ran
        gan_toa_do [di], [si], 'x'         ;in than con ran
        
        inc si                             ;tang chi so di
        inc di                             ;tang chi so si
        jmp lapin                          ;lap lai vong lap in than con ran
    ket:
        gan_toa_do [di], [si], 'X'         ;in dau con ran
    ret
in_ran endp 

;in ra man hinh ket thuc thang hay thua
ket_thuc proc
    
    call xoa_man_hinh                       ;xoa het ki tu tren man hinh hien thi
    di_chuyen_con_tro 10, 20                ;di chuyen con tro toi vi tri 10, 20
    mov dl, score                           ;luu gia tri diem vao thanh dl
    cmp dl, score_max                       ;xem nguoi choi co chien thang
    jl thua                                 ;neu nguoi choi dat duoc so diem < diem_max -> thua cuoc
    in_thong_bao kq2                        ;nguoc lai thi nguoi choi se thang
    jmp het                                 ;nhay den ham het de tiep tuc xu li
    
thua:
    in_thong_bao kq1                        ;in khi thua cuoc
    mov ah, 2                               ;chon che do in 1 ki tu
    mov dl, score                           ;luu gia tri diem vao dl
    add dl, '0'                             ;chuyen diem dang so sang kieu ki tu
    int 21h                                 ;hien thi diem dat duoc
    
het:                                        ;ket thuc in diem 
    di_chuyen_con_tro 12, 20                ;di chuyen con tro toi vi tri 12, 20
    in_thong_bao tb_choi_lai                ;in ra thong bao hoi nguoi choi co muon choi lai khong
    
    mov ah, 1                               ;chon che do nhap mot ki tu tu ban phim 
    int 21h                                 ;goi ham ngat 21h de lay 1 ki tu vua nhap
    cmp al, 'y'                             ;neu nguoi choi nhap 'y' nghia la "yes"
    je choi_lai                             ;chuong trinh nhay toi ham choi_lai de tiep tuc xu li
    
    cmp al, 'n'                             ;neu nguoi choi nhap 'n' nghia la "no"
    je nghi_game                            ;chuong trinh nhay toi ham nghi_game de tiep tuc xu li
    
choi_lai:
    pusha                                   ;luu toan bo thanh ghi de tranh anh huong chuong trinh chinh
    mov dh, 10                              ;gan toa_do_x con ran = dh
    mov snake_x, dh                         ;reset lai toa do ban dau con ran duoc in ra
    mov dl, 40                              ;gan toa_do_x con ran = dl
    mov snake_y, dl                         ;reset lai toa do ban dau con ran duoc in ra
    mov old_key, 'g'                        ;reset lai huong di chuyen cu la 1 ki tu khong phai phim dieu khien
    mov cl, 0                               ;reset chieu dai con ran ve 0
    mov len_snake, cl  
    mov al, 0                               ;reset so diem tro lai ve 0
    mov score, al
    popa                                    ;khoi phuc toan bo thanh ghi
    jmp choi_game                           ;bat dau man choi moi
    
nghi_game:  
    call xoa_man_hinh                       ;xoa het ki tu xuat hien tren man hinh hien thi
        di_chuyen_con_tro 9, 20             ;di chuyen con tro toi vi tri 9, 20
    in_thong_bao end1                       ;in ra thong bao end1 (ten game) 
        di_chuyen_con_tro 11, 20            ;di chuyen con tro toi vi tri 13, 20
    in_thong_bao end2                       ;in ra ten nhom
        di_chuyen_con_tro 13, 16            ;di chuyen con tro toi vi tri 9, 20
    in_thong_bao end3                       ;in hoa tiet trang tri
        di_chuyen_con_tro 15, 20            ;di chuyen con tro toi vi tri 9, 20
    in_thong_bao end4                       ;in ra loi cam on
    
    mov ah ,4ch                             ;chon che do ket thuc chuong trinh   
    int 21h                                 ;dung ham ngat 21h de ket thuc chuong trinh
    
ket_thuc endp

;hien thong bao va so diem cua nguoi choi
hiendiem proc
    di_chuyen_con_tro 3, 35     ;dua con tro toi vi tri khac de hien diem
    in_thong_bao diem1          ;in chuoi ki tu "score: "
    mov ah, 2                   ;che do in 1 ki tu ham ngat 21h
    mov dl, score               ;luu diem da dat duoc vao thanh dl
    add dl, '0'                 ;chuyen so diem sang dang ki tu
    int 21h                     ;thuc hien lenh in diem
    ret
hiendiem endp

;hien thong bao huong dan nguoi choi game snake
huongdan proc 
    call xoa_man_hinh           ;xoa het ki tu xuat hien tren man hinh
    mov dh, begin_row           ;khoi tao hang dau tien
    mov dl, begin_column        ;khoi tao cot dau tien
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd1            ;in thong bao huong dan 1
   
    add dh, 2                   ;tang hang them 2 va thuc hien in tiep
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd2            ;in thong bao hd2
    
    add dl, 10                  ;tang cot them 10 de in huong dan cac phim dieu khien
    add dh, 2                   ;tang hang them 2 va thuc hien in tiep
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd4            ;in hd4
    add dh, 1                   ;tang dh = chi so hang len 1
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd5            ;in hd5
    add dh, 1                   ;tang chi so hang dh toi hang tiep theo
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd6            ;in hd6
    add dh, 1                   ;tang chi so hang dh toi hang tiep theo
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd7            ;in hd7
    
    add dh, 3                   ;tang chi so hang dh len 3
    sub dl, 10                  ;giam chi so cot dl xuong 10
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd8            ;in thong bao hd8
    
    add dl, 5                   ;tang chi so cot dl len 5
    add dh, 1                   ;tang chi so hang dh len 1 xuong hang tiep theo
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd9            ;in thong bao hd9
    add dh, 1                   ;tang chi so hang toi hang tiep theo
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd10           ;in hd10
    add dh, 1                   ;tang chi so hang toi vi tri tiep theo
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh, dl
    in_thong_bao hd11           ;in hd11
    add dh, 1                   ;tang chi so hang toi vi tri tiep theo
    di_chuyen_con_tro dh, dl    ;di chuyen con tro toi vi tri dh,dl
    in_thong_bao hd12           ;in hd12
    
    ret                         ;return
huongdan endp

;hien thi hang rao "#"
border proc
    pusha                                       ;luu het gia tri thanh ghi vao trong stack
    di_chuyen_con_tro begin_row, begin_column   ;dua con tro toi vi tri begin_row, begin_column 
    in_thong_bao border_row                     ;in hang rao phia tren
    di_chuyen_con_tro end_row, begin_column     ;dua con tro toi vi tri end_row, begin_column
    in_thong_bao border_row                     ;in hang rao phia duoi
    mov cl, begin_row                           ;luu hang in dau tien vao thanh ghi cl
    lap:                                        ;nhan thuc hien in ki tu '#' theo chieu doc
        gan_toa_do cl, begin_column, '#'        ;in 1 ki tu hang rao ben trai
        gan_toa_do cl, end_column, '#'          ;in 1 ki tu hang rao ben phai
        inc cl                                  ;tang vi tri hang them 1 
        cmp cl, end_row                         ;so sanh vi tri hang cuoi hay chua
        jng lap                                 ;tiep tuc in hang rao
    popa                                        ;lay het gia tri da luu ra khoi stack va gan vao tung thanh ghi
    ret                                         ;return
border endp   

;xoa het ki tu xuat hien tren man hinh de man hinh tro ve dang chu trang nen den
xoa_man_hinh proc
    mov ah, 06h       ; su dung ham cuon man hinh (scroll window) - int 10h, ah = 06h
    mov al, 0         ; so dong cuon = 0 -> nghia la cuon toan bo -> xoa toan man hinh
    mov bh, 07h       ; xoa chu trang tren nen den
    mov cx, 0000h     ; gan toa do goc tren ben trai cho thanh ghi cx (row = 0, col = 0)
    mov dx, 184Fh     ; toa do goc duoi ben phai (row = 24, col = 79) -> xoa het man hinh 80x25
    int 10h           ; goi ham ngat 10h de thuc hien lenh xoa
    ret 
xoa_man_hinh endp


