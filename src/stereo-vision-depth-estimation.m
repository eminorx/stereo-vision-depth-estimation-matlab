%  Computer Vision - Stereo Vizyon Projesi
%  Emin Imanov 20210855806 
%
%  Notlar:
%  Fotoğraf adlarını aşağıdaki gibidir
%       sol.jpg.jpeg
%       sag.jpg.jpeg
%  
%  Ölçüm ve tablolar için kullandığım nesne sırası:
%  1  - ZPIX Sprey
%  2  - Kalemlik
%  3  - Gozluk Kutusu
%  4  - Altin Silindir
%  5  - Neutrogena
%  6  - Kirmizi Kutu
%  7  - Zimba
%  8  - Siyah Kavanoz
%  9  - ZMA Sise
%  10 - Matara

clear; clc; close all;

fprintf('=== STEREO VIZYON PROJESI BASLADI ===\n\n');

%%  Fotograf yolları tanımlanıyor

img1_path = 'sol.jpg.jpeg';
img2_path = 'sag.jpg.jpeg';

B = 0.10;   % Fotoğraf çekerken kamera 10 cm yana kaydırıldı

% Metre ile ölçtüğüm gerçek uzaklık değerleri. Hesapta metre kullanıldığı için cm değerlerini metreye çevirdim.
Z_gercek = [
    0.80;  % 1  - ZPIX Sprey
    0.94;  % 2  - Kalemlik
    0.74;  % 3  - Gozluk Kutusu
    1.03;  % 4  - Altin Silindir
    0.82;  % 5  - Neutrogena 
    1.08;  % 6  - Kirmizi Kutu
    0.77;  % 7  - Zimba
    0.96;  % 8  - Siyah Kavanoz
    0.86;  % 9  - ZMA Sise
    0.96   % 10 - Matara
];

nesne_adlari = {
    'ZPIX Sprey'
    'Kalemlik'
    'Gozluk Kutusu'
    'Altin Silindir'
    'Neutrogena'
    'Kirmizi Kutu'
    'Zimba'
    'Siyah Kavanoz'
    'ZMA Sise'
    'Matara'
};

GURULTU_YOGUNLUGU = 0.03;

%%  ADIM 1 - Fotoğrafları okuma

fprintf('[ADIM 1] Resimler yukleniyor...\n');

img1 = imread(img1_path);
img2 = imread(img2_path);

[h1, w1, ~] = size(img1);
[h2, w2, ~] = size(img2);

fprintf('  Sol goruntu boyutu: %d x %d piksel\n', w1, h1);
fprintf('  Sag goruntu boyutu: %d x %d piksel\n', w2, h2);

if h1 ~= h2 || w1 ~= w2
    error('Sol ve sag goruntulerin boyutlari ayni degil!');
end

figure('Name','ADIM 1 - Orijinal Stereo Goruntu Cifti', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0 0.5 1 0.5]);

subplot(1,2,1);
imshow(img1);
title('Sol Goruntu', 'FontSize', 13, 'FontWeight', 'bold');

subplot(1,2,2);
imshow(img2);
title('Sag Goruntu', 'FontSize', 13, 'FontWeight', 'bold');

sgtitle('ADIM 1: Orijinal Stereo Goruntu Cifti', ...
        'FontSize', 14, 'FontWeight', 'bold');

%%  ADIM 2 - Görüntülere salt & pepper gürültüsü ekleme

fprintf('[ADIM 2] Salt & pepper gurultusu ekleniyor...\n');

img1_gurultulu = imnoise(img1, 'salt & pepper', GURULTU_YOGUNLUGU);
img2_gurultulu = imnoise(img2, 'salt & pepper', GURULTU_YOGUNLUGU);

figure('Name','ADIM 2 - Salt & Pepper Gurultulu Goruntuler', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0 0 1 0.5]);

subplot(1,2,1);
imshow(img1_gurultulu);
title('Sol Goruntu - Gurultulu', 'FontSize', 13, 'FontWeight', 'bold');

subplot(1,2,2);
imshow(img2_gurultulu);
title('Sag Goruntu - Gurultulu', 'FontSize', 13, 'FontWeight', 'bold');

sgtitle('ADIM 2: Salt & Pepper Gurultusu Eklenmis Goruntuler', ...
        'FontSize', 14, 'FontWeight', 'bold');

%%  ADIM 3 - Median filtre ile gürültüyü azaltma

fprintf('[ADIM 3] Median filtre uygulanıyor...\n');

img1_temiz = filtrele_rgb_median(img1_gurultulu, [3 3]);
img2_temiz = filtrele_rgb_median(img2_gurultulu, [3 3]);

figure('Name','ADIM 3 - Median Filtre Sonrasi', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0 0.5 1 0.5]);

subplot(1,2,1);
imshow(img1_temiz);
title('Sol Goruntu - Median Filtre Sonrasi', 'FontSize', 13, 'FontWeight', 'bold');

subplot(1,2,2);
imshow(img2_temiz);
title('Sag Goruntu - Median Filtre Sonrasi', 'FontSize', 13, 'FontWeight', 'bold');

sgtitle('ADIM 3: Median Filtre ile Gurultu Giderme', ...
        'FontSize', 14, 'FontWeight', 'bold');

%%  ADIM 4 - Nesneleri ROI bölgeleri içinde ayırma

fprintf('[ADIM 4] Sabit ROI + otomatik lokal segmentasyon yapiliyor...\n');

% ROI değerleri [x, y, genişlik, yükseklik] şeklinde verildi.
% Buradaki x ve y, kutunun sol üst köşesini gösteriyor.
% Koordinatları kendi çektiğim 1280x960 fotoğraflara göre ayarladım.
% Fotoğraflar kırpılırsa, yeniden boyutlandırılırsa ya da nesnelerin yeri
% değişirse bu kutuların da tekrar ayarlanması gerekir.

roi_sol = [
    350 570  90 270;   % 1  - ZPIX Sprey
    440 625 110 160;   % 2  - Kalemlik
    555 705 145 145;   % 3  - Gozluk Kutusu
    595 575 105 180;   % 4  - Altin Silindir
    720 665  95 165;   % 5  - Neutrogena
    720 555 100 165;   % 6  - Kirmizi Kutu
    840 720 105 135;   % 7  - Zimba
    865 585 155 190;   % 8  - Siyah Kavanoz
    1040 670 105 155;  % 9  - ZMA Sise
    1090 475 125 330   % 10 - Matara
];

roi_sag = [
    155 575  90 270;   % 1  - ZPIX Sprey
    265 625 115 160;   % 2  - Kalemlik
    385 705 145 150;   % 3  - Gozluk Kutusu
    455 575 105 180;   % 4  - Altin Silindir
    535 665  95 165;   % 5  - Neutrogena
    575 555 100 165;   % 6  - Kirmizi Kutu
    660 720 105 135;   % 7  - Zimba
    710 585 155 190;   % 8  - Siyah Kavanoz
    860 670 105 155;   % 9  - ZMA Sise
    920 475 125 330    % 10 - Matara
];

bw1 = segmente_sabit_roi(img1_temiz, roi_sol);
bw2 = segmente_sabit_roi(img2_temiz, roi_sag);

N1 = max(bw1(:));
N2 = max(bw2(:));

fprintf('  Sol goruntude tespit edilen nesne sayisi: %d\n', N1);
fprintf('  Sag goruntude tespit edilen nesne sayisi: %d\n', N2);

figure('Name','ADIM 4 - Sabit ROI Segmentasyon Maskeleri', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0 0 1 0.5]);

subplot(1,2,1);
imshow(label2rgb(uint8(bw1), 'jet', 'k'));
title(sprintf('Sol Maske - %d nesne', N1), 'FontSize', 13, 'FontWeight', 'bold');

subplot(1,2,2);
imshow(label2rgb(uint8(bw2), 'jet', 'k'));
title(sprintf('Sag Maske - %d nesne', N2), 'FontSize', 13, 'FontWeight', 'bold');

sgtitle('ADIM 4: Sabit ROI + Otomatik Lokal Segmentasyon', ...
        'FontSize', 14, 'FontWeight', 'bold');

% ROI kutularını ayrıca gösteriyorum; böylece kutular nesnelerin üstüne düzgün oturmuş mu kontrol edilebiliyor.
figure('Name','ADIM 4 Kontrol - ROI Kutulari', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0 0.05 1 0.9]);

subplot(1,2,1);
imshow(img1);
hold on;
for k = 1:size(roi_sol,1)
    rectangle('Position', roi_sol(k,:), 'EdgeColor','y', 'LineWidth',2);
    text(roi_sol(k,1), roi_sol(k,2)-8, sprintf('#%d',k), ...
         'Color','yellow','FontSize',12,'FontWeight','bold', ...
         'BackgroundColor','black');
end
title('Sol Goruntu ROI Kutulari', 'FontSize', 13, 'FontWeight', 'bold');
hold off;

subplot(1,2,2);
imshow(img2);
hold on;
for k = 1:size(roi_sag,1)
    rectangle('Position', roi_sag(k,:), 'EdgeColor','y', 'LineWidth',2);
    text(roi_sag(k,1), roi_sag(k,2)-8, sprintf('#%d',k), ...
         'Color','yellow','FontSize',12,'FontWeight','bold', ...
         'BackgroundColor','black');
end
title('Sag Goruntu ROI Kutulari', 'FontSize', 13, 'FontWeight', 'bold');
hold off;

sgtitle('Kontrol: Sabit ROI Kutulari', 'FontSize', 14, 'FontWeight', 'bold');

%%  ADIM 5 - Nesnelerin merkez, kutu ve elips bilgilerini çıkarma

fprintf('[ADIM 5] Centroid, Bounding Box ve Equivalent Ellipse hesaplaniyor...\n');

props1 = regionprops(bw1, ...
    'Centroid', ...
    'BoundingBox', ...
    'MajorAxisLength', ...
    'MinorAxisLength', ...
    'Orientation', ...
    'Area', ...
    'Perimeter', ...
    'PixelIdxList');

props2 = regionprops(bw2, ...
    'Centroid', ...
    'BoundingBox', ...
    'MajorAxisLength', ...
    'MinorAxisLength', ...
    'Orientation', ...
    'Area', ...
    'Perimeter', ...
    'PixelIdxList');

figure('Name','ADIM 5 - Sol Goruntu Nesne Tespiti', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0 0 0.5 1]);

imshow(img1);
hold on;
for i = 1:length(props1)
    if i <= length(nesne_adlari)
        ad = nesne_adlari{i};
    else
        ad = sprintf('Nesne-%d', i);
    end
    ciz_nesne(props1(i), i, ad);
end
title('Sol Goruntu: Centroid, Bounding Box, Equivalent Ellipse', ...
      'FontSize', 12, 'FontWeight', 'bold');
hold off;

figure('Name','ADIM 5 - Sag Goruntu Nesne Tespiti', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0.5 0 0.5 1]);

imshow(img2);
hold on;
for i = 1:length(props2)
    if i <= length(nesne_adlari)
        ad = nesne_adlari{i};
    else
        ad = sprintf('Nesne-%d', i);
    end
    ciz_nesne(props2(i), i, ad);
end
title('Sag Goruntu: Centroid, Bounding Box, Equivalent Ellipse', ...
      'FontSize', 12, 'FontWeight', 'bold');
hold off;

%%  ADIM 6 - Şekil özelliklerini hesaplama

fprintf('[ADIM 6] Aspect ratio, circularity ve Hu momentleri hesaplaniyor...\n');

[ar1, circ1, hu1] = hesapla_ozellikler(bw1, props1);
[ar2, circ2, hu2] = hesapla_ozellikler(bw2, props2);

T_sol = tablo_olustur(nesne_adlari, props1, ar1, circ1, hu1);
T_sag = tablo_olustur(nesne_adlari, props2, ar2, circ2, hu2);

fprintf('\n=== SOL GORUNTU NESNE OZELLIKLERI ===\n');
disp(T_sol);

fprintf('\n=== SAG GORUNTU NESNE OZELLIKLERI ===\n');
disp(T_sag);

figure('Name','ADIM 6 - Sol Goruntu Ozellik Tablosu', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0 0 0.95 0.5]);

uitable('Data', table2cell(T_sol), ...
        'ColumnName', T_sol.Properties.VariableNames, ...
        'Units','normalized', ...
        'Position',[0.02 0.02 0.96 0.96], ...
        'FontSize', 9);

figure('Name','ADIM 6 - Sag Goruntu Ozellik Tablosu', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0.02 0.08 0.95 0.5]);

uitable('Data', table2cell(T_sag), ...
        'ColumnName', T_sag.Properties.VariableNames, ...
        'Units','normalized', ...
        'Position',[0.02 0.02 0.96 0.96], ...
        'FontSize', 9);

%%  ADIM 7 - Nesneleri SSD metriği ile karşılaştırma

fprintf('[ADIM 7] SSD ile nesne eslestirme yapiliyor...\n');

feat1 = ozellik_vektoru_olustur(ar1, circ1, hu1);
feat2 = ozellik_vektoru_olustur(ar2, circ2, hu2);

N_left  = size(feat1, 1);
N_right = size(feat2, 1);
N = min(N_left, N_right);

SSD_mat = zeros(N_left, N_right);

for i = 1:N_left
    for j = 1:N_right
        fark = feat1(i,:) - feat2(j,:);
        SSD_mat(i,j) = sum(fark .^ 2);
    end
end

% Her sağ görüntü nesnesi yalnızca bir kez kullanılacak şekilde en küçük SSD değerlerini seçiyorum.
eslesen = zeros(N, 2);
ssd_degerler = zeros(N, 1);

kullanilan_sol = false(N_left, 1);
kullanilan_sag = false(N_right, 1);

for k = 1:N
    temp = SSD_mat;
    temp(kullanilan_sol, :) = inf;
    temp(:, kullanilan_sag) = inf;

    [min_ssd, idx] = min(temp(:));
    [i_best, j_best] = ind2sub(size(temp), idx);

    eslesen(k,:) = [i_best, j_best];
    ssd_degerler(k) = min_ssd;

    kullanilan_sol(i_best) = true;
    kullanilan_sag(j_best) = true;
end

sol_no = eslesen(:,1);
sag_no = eslesen(:,2);

sol_ad = cell(N,1);
sag_ad = cell(N,1);

for k = 1:N
    if sol_no(k) <= length(nesne_adlari)
        sol_ad{k} = nesne_adlari{sol_no(k)};
    else
        sol_ad{k} = sprintf('Nesne-%d', sol_no(k));
    end

    if sag_no(k) <= length(nesne_adlari)
        sag_ad{k} = nesne_adlari{sag_no(k)};
    else
        sag_ad{k} = sprintf('Nesne-%d', sag_no(k));
    end
end

T_ssd = table( ...
    (1:N)', ...
    sol_no, ...
    sol_ad, ...
    sag_no, ...
    sag_ad, ...
    ssd_degerler, ...
    'VariableNames', {'MatchNo','SolNesneNo','SolNesneAdi','SagNesneNo','SagNesneAdi','SSD'} ...
);

fprintf('\n=== SSD ESLESTIRME TABLOSU ===\n');
disp(T_ssd);

figure('Name','ADIM 7 - SSD Eslesme Tablosu', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0.1 0.1 0.8 0.5]);

uitable('Data', table2cell(T_ssd), ...
        'ColumnName', T_ssd.Properties.VariableNames, ...
        'Units','normalized', ...
        'Position',[0.02 0.02 0.96 0.96], ...
        'FontSize', 10);

% Karşılaştırmayı daha rahat görmek için SSD matrisini de çizdiriyorum.
figure('Name','ADIM 7 - SSD Matrisi', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0.2 0.1 0.6 0.7]);

imagesc(SSD_mat);
colorbar;
xlabel('Sag Goruntu Nesne No');
ylabel('Sol Goruntu Nesne No');
title('SSD Karsilastirma Matrisi', 'FontSize', 13, 'FontWeight', 'bold');
axis equal tight;

%%  ADIM 8 - Disparite değerlerini hesaplama

fprintf('[ADIM 8] Disparite hesaplaniyor...\n');

% ROI'leri nesne sırasına göre verdiğim için aynı numaralar aynı nesneyi temsil ediyor:
% sol 1 <-> sağ 1, sol 2 <-> sağ 2, ...
% Bu yüzden dispariteyi aynı numaralı nesnelerin merkezleri arasında hesapladım.

N_obj = min([length(props1), length(props2), length(Z_gercek), length(nesne_adlari)]);

cx_sol = zeros(N_obj, 1);
cy_sol = zeros(N_obj, 1);
cx_sag = zeros(N_obj, 1);
cy_sag = zeros(N_obj, 1);
d_values = zeros(N_obj, 1);

for k = 1:N_obj
    cx_sol(k) = props1(k).Centroid(1);
    cy_sol(k) = props1(k).Centroid(2);

    cx_sag(k) = props2(k).Centroid(1);
    cy_sag(k) = props2(k).Centroid(2);

    % Disparite, iki görüntüdeki merkezlerin yatay eksendeki piksel farkıdır.
    d_values(k) = abs(cx_sol(k) - cx_sag(k));
end

T_disparite = table( ...
    (1:N_obj)', ...
    nesne_adlari(1:N_obj), ...
    cx_sol, ...
    cy_sol, ...
    cx_sag, ...
    cy_sag, ...
    d_values, ...
    Z_gercek(1:N_obj), ...
    1 ./ Z_gercek(1:N_obj), ...
    'VariableNames', {'No','Nesne','Cx_Sol','Cy_Sol','Cx_Sag','Cy_Sag','Disparite_px','Z_m','BirBolumZ'} ...
);

fprintf('\n=== DISPARITE VE Z TABLOSU ===\n');
disp(T_disparite);

figure('Name','ADIM 8 - Disparite ve Z Tablosu', ...
       'NumberTitle','off','Units','normalized','OuterPosition',[0.05 0.1 0.9 0.5]);

uitable('Data', table2cell(T_disparite), ...
        'ColumnName', T_disparite.Properties.VariableNames, ...
        'Units','normalized', ...
        'Position',[0.02 0.02 0.96 0.96], ...
        'FontSize', 10);

%%  ADIM 9 - d ile 1/Z grafiği ve fokal uzunluk hesabı

fprintf('[ADIM 9] d vs 1/Z grafigi ciziliyor ve fokal uzunluk hesaplaniyor...\n');

inv_Z = 1 ./ Z_gercek(1:N_obj);
d_plot = d_values;

gecerli = isfinite(inv_Z) & isfinite(d_plot) & d_plot > 0;

inv_Z_gecerli = inv_Z(gecerli);
d_gecerli = d_plot(gecerli);

if sum(gecerli) < 2
    warning('Lineer fit icin yeterli gecerli disparite noktasi yok.');
else
    % Kullanılan ilişki:
    % Z = fB / d
    % Buradan d = fB * (1/Z) elde edilir.
    % Yani grafiğin eğimi fB değerini verir.

    p = polyfit(inv_Z_gecerli, d_gecerli, 1);

    egim = p(1);
    kesim = p(2);

    f_piksel = egim / B;

    d_tahmin = polyval(p, inv_Z_gecerli);

    SS_res = sum((d_gecerli - d_tahmin).^2);
    SS_tot = sum((d_gecerli - mean(d_gecerli)).^2);

    if SS_tot == 0
        R2 = NaN;
    else
        R2 = 1 - SS_res / SS_tot;
    end

    figure('Name','ADIM 9 - d vs 1/Z Grafigi', ...
           'NumberTitle','off','Units','normalized','OuterPosition',[0.2 0.1 0.7 0.8]);

    scatter(inv_Z_gecerli, d_gecerli, 100, 'filled');
    hold on;

    x_fit = linspace(min(inv_Z_gecerli)*0.95, max(inv_Z_gecerli)*1.05, 200);
    y_fit = polyval(p, x_fit);

    plot(x_fit, y_fit, 'LineWidth', 2);

    for k = 1:N_obj
        if gecerli(k)
            text(inv_Z(k)+0.005, d_values(k), nesne_adlari{k}, ...
                 'FontSize', 9, 'FontWeight', 'bold');
        end
    end

    grid on;
    xlabel('1/Z  (1/m)', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Disparite d  (piksel)', 'FontSize', 13, 'FontWeight', 'bold');

    title(sprintf('d vs 1/Z Grafigi | Eğim = fB = %.3f | f = %.3f piksel | R^2 = %.4f', ...
          egim, f_piksel, R2), ...
          'FontSize', 12, 'FontWeight', 'bold');

    legend('Olcum noktalari', ...
           sprintf('Lineer fit: d = %.3f(1/Z) + %.3f', egim, kesim), ...
           'Location', 'best');

    hold off;

    fprintf('\n=== FOKAL UZUNLUK SONUCLARI ===\n');
    fprintf('  Lineer model: d = egim * (1/Z) + kesim\n');
    fprintf('  Eğim = f * B = %.4f piksel.metre\n', egim);
    fprintf('  Kesim = %.4f piksel\n', kesim);
    fprintf('  B = %.4f metre\n', B);
    fprintf('  f = egim / B = %.4f piksel\n', f_piksel);
    fprintf('  R^2 = %.4f\n', R2);
end

%%  ADIM 10 - Tabloları dosya olarak kaydetme

fprintf('[ADIM 10] Sonuc tablolari CSV dosyasi olarak kaydediliyor...\n');

writetable(T_sol, 'sol_goruntu_ozellikleri.csv');
writetable(T_sag, 'sag_goruntu_ozellikleri.csv');
writetable(T_ssd, 'ssd_eslestirme_tablosu.csv');
writetable(T_disparite, 'disparite_z_tablosu.csv');

fprintf('\nCSV dosyalari kaydedildi:\n');
fprintf('  sol_goruntu_ozellikleri.csv\n');
fprintf('  sag_goruntu_ozellikleri.csv\n');
fprintf('  ssd_eslestirme_tablosu.csv\n');
fprintf('  disparite_z_tablosu.csv\n');

fprintf('\n PROJE TAMAMLANDI \n');

%%  Kodun sonunda kullandığım yardımcı fonksiyonlar

function img_out = filtrele_rgb_median(img_in, pencere)
% Renkli görüntüde median filtreyi her kanala ayrı ayrı uyguluyorum.

    r = medfilt2(img_in(:,:,1), pencere);
    g = medfilt2(img_in(:,:,2), pencere);
    b = medfilt2(img_in(:,:,3), pencere);

    img_out = cat(3, r, g, b);
end

function bw_labeled = segmente_sabit_roi(img, roi_list)
% Verilen ROI kutularının içinden her nesne için ayrı bir maske çıkarıyorum.
% Burada elle çizim yapılmıyor; kutular daha önce belirlenmiş durumda.
%
% Çıktı:
%   bw_labeled: Her nesnenin farklı numara ile gösterildiği etiketli maske.

    [H, W, ~] = size(img);
    bw_labeled = zeros(H, W);

    for k = 1:size(roi_list, 1)

        x = roi_list(k, 1);
        y = roi_list(k, 2);
        w = roi_list(k, 3);
        h = roi_list(k, 4);

        x1 = max(1, round(x));
        y1 = max(1, round(y));
        x2 = min(W, round(x + w - 1));
        y2 = min(H, round(y + h - 1));

        crop = img(y1:y2, x1:x2, :);

        local_mask = lokal_roi_maske(crop, k);

        oran = nnz(local_mask) / numel(local_mask);

        % Maske aşırı küçük ya da neredeyse tüm ROI kadar büyük çıkarsa yaklaşık bir elips maske kullanıyorum.
        if oran < 0.03 || oran > 0.90
            local_mask = fallback_elips_maske(size(local_mask,1), size(local_mask,2));
        end

        temp = false(H, W);
        temp(y1:y2, x1:x2) = local_mask;

        bw_labeled(temp) = k;
    end

    bw_labeled = uint8(bw_labeled);
end

function mask = lokal_roi_maske(crop, nesne_no)
% Küçük ROI parçasının içinde nesneyi arka plandan ayırmaya çalışıyorum.
% Tüm görüntü yerine küçük bir bölgede çalışmak bu sahnede daha kararlı sonuç verdi.

    crop_d = im2double(crop);

    hsv_img = rgb2hsv(crop_d);
    S = hsv_img(:,:,2);
    V = hsv_img(:,:,3);

    gray = rgb2gray(crop_d);

    % Renk, koyuluk ve parlaklık bilgilerini ayrı ayrı aday maske olarak kullandım.
    renkli = S > 0.13;
    koyu   = V < 0.58;
    beyaz  = (V > 0.68) & (S < 0.38);

    % Kenar bilgisini de ekledim; bazı nesneler sadece renk eşikleme ile tam çıkmıyor.
    kenar = edge(gray, 'Canny');
    kenar = imdilate(kenar, strel('disk', 1));
    kenar = imfill(kenar, 'holes');

    % Bazı nesnelerin rengi farklı olduğu için her nesne için küçük ayarlar yaptım.
    switch nesne_no

        case 1
            % ZPIX daha çok beyaz ve etiketli bir nesne olduğu için
            mask = beyaz | renkli | kenar;

        case 2
            % Kalemlik koyu renkli olduğu için
            mask = koyu | kenar;

        case 3
            % Gözlük kutusu koyu renkli olduğu için
            mask = koyu | kenar;

        case 4
            % Altın silindirde renk bilgisi belirgin olduğu için
            mask = renkli | koyu | kenar;

        case 5
            % Neutrogena tüpünde beyaz ve renkli bölgeler olduğu için
            mask = beyaz | renkli | kenar;

        case 6
            % Kırmızı kutuda renk bilgisi baskın olduğu için
            mask = renkli | koyu | kenar;

        case 7
            % Zımba koyu renkli olduğu için
            mask = koyu | kenar;

        case 8
            % Siyah kavanozda koyu bölge ve etiket birlikte kullanıldı.
            mask = koyu | renkli | kenar;

        case 9
            % ZMA şişesi beyaz ve etiketli olduğu için
            mask = beyaz | renkli | kenar;

        case 10
            % Matara koyu renkli olduğu için
            mask = koyu | renkli | kenar;

        otherwise
            mask = renkli | koyu | beyaz | kenar;
    end

    % Maskedeki küçük boşlukları ve kopuklukları temizliyorum.
    mask = imclose(mask, strel('disk', 3));
    mask = imopen(mask, strel('disk', 1));
    mask = imfill(mask, 'holes');
    mask = bwareaopen(mask, 40);

    % ROI içinde en büyük bağlı parçayı nesne olarak kabul ettim.
    CC = bwconncomp(mask);

    if CC.NumObjects > 0
        alanlar = cellfun(@numel, CC.PixelIdxList);
        [~, idx] = max(alanlar);

        temiz = false(size(mask));
        temiz(CC.PixelIdxList{idx}) = true;
        mask = temiz;
    else
        mask = false(size(mask));
    end

    mask = imclose(mask, strel('disk', 3));
    mask = imfill(mask, 'holes');
end

function mask = fallback_elips_maske(h, w)
% Lokal maske düzgün çıkmazsa, ROI merkezinde yaklaşık bir elips kullanıyorum.

    [X, Y] = meshgrid(1:w, 1:h);

    cx = w / 2;
    cy = h / 2;

    a = w * 0.42;
    b = h * 0.45;

    mask = ((X - cx).^2 / a^2 + (Y - cy).^2 / b^2) <= 1;

    mask = imfill(mask, 'holes');
end

function ciz_nesne(prop, idx, ad)
% Görüntü üzerine merkez noktası, sınırlayıcı kutu ve eşdeğer elipsi çiziyorum.

    cx = prop.Centroid(1);
    cy = prop.Centroid(2);

    bb = prop.BoundingBox;

    % Merkez noktası
    plot(cx, cy, 'r+', 'MarkerSize', 14, 'LineWidth', 2.5);

    % Sınırlayıcı kutu
    rectangle('Position', bb, ...
              'EdgeColor', 'g', ...
              'LineWidth', 2);

    % Eşdeğer elips
    a = prop.MajorAxisLength / 2;
    b = prop.MinorAxisLength / 2;

    if a > 0 && b > 0
        theta = linspace(0, 2*pi, 150);
        angle = -prop.Orientation * pi / 180;

        x = a * cos(theta);
        y = b * sin(theta);

        R = [cos(angle) -sin(angle); sin(angle) cos(angle)];
        coords = R * [x; y];

        x_ell = coords(1,:) + cx;
        y_ell = coords(2,:) + cy;

        plot(x_ell, y_ell, 'c-', 'LineWidth', 2);
    end

    % Nesne etiketi
    text(bb(1), bb(2)-10, sprintf('#%d %s', idx, ad), ...
         'Color','yellow', ...
         'FontSize',10, ...
         'FontWeight','bold', ...
         'BackgroundColor','black');
end

function [ar, circ, hu_mat] = hesapla_ozellikler(bw_labeled, props)
% Her nesne için şekil tabanlı özellikleri hesaplıyorum.

    N = length(props);

    ar = zeros(N, 1);
    circ = zeros(N, 1);
    hu_mat = zeros(N, 7);

    for i = 1:N

        % Aspect ratio için elipsin büyük eksenini küçük eksenine böldüm.
        if props(i).MinorAxisLength > 0
            ar(i) = props(i).MajorAxisLength / props(i).MinorAxisLength;
        else
            ar(i) = NaN;
        end

        % Circularity değeri nesnenin daireye ne kadar benzediğini gösteriyor.
        if props(i).Perimeter > 0
            circ(i) = 4 * pi * props(i).Area / (props(i).Perimeter ^ 2);
        else
            circ(i) = NaN;
        end

        maske = (bw_labeled == i);
        hu_mat(i,:) = hesapla_hu_momentleri(maske);
    end
end

function hu = hesapla_hu_momentleri(mask)
% İkili maske üzerinden 7 Hu momentini hesaplıyorum.
% Değerler çok farklı büyüklüklerde olabildiği için log dönüşümü kullandım.

    mask = double(mask);

    [rows, cols] = size(mask);
    [X, Y] = meshgrid(1:cols, 1:rows);

    m00 = sum(mask(:));

    if m00 == 0
        hu = zeros(1, 7);
        return;
    end

    m10 = sum(sum(X .* mask));
    m01 = sum(sum(Y .* mask));

    x_bar = m10 / m00;
    y_bar = m01 / m00;

    x = X - x_bar;
    y = Y - y_bar;

    mu20 = sum(sum((x.^2) .* mask));
    mu02 = sum(sum((y.^2) .* mask));
    mu11 = sum(sum((x .* y) .* mask));

    mu30 = sum(sum((x.^3) .* mask));
    mu03 = sum(sum((y.^3) .* mask));
    mu21 = sum(sum((x.^2 .* y) .* mask));
    mu12 = sum(sum((x .* y.^2) .* mask));

    eta20 = mu20 / (m00 ^ 2);
    eta02 = mu02 / (m00 ^ 2);
    eta11 = mu11 / (m00 ^ 2);

    eta30 = mu30 / (m00 ^ 2.5);
    eta03 = mu03 / (m00 ^ 2.5);
    eta21 = mu21 / (m00 ^ 2.5);
    eta12 = mu12 / (m00 ^ 2.5);

    hu_raw = zeros(1, 7);

    hu_raw(1) = eta20 + eta02;

    hu_raw(2) = (eta20 - eta02)^2 + 4 * eta11^2;

    hu_raw(3) = (eta30 - 3*eta12)^2 + ...
                (3*eta21 - eta03)^2;

    hu_raw(4) = (eta30 + eta12)^2 + ...
                (eta21 + eta03)^2;

    hu_raw(5) = (eta30 - 3*eta12) * (eta30 + eta12) * ...
                ((eta30 + eta12)^2 - 3*(eta21 + eta03)^2) + ...
                (3*eta21 - eta03) * (eta21 + eta03) * ...
                (3*(eta30 + eta12)^2 - (eta21 + eta03)^2);

    hu_raw(6) = (eta20 - eta02) * ...
                ((eta30 + eta12)^2 - (eta21 + eta03)^2) + ...
                4 * eta11 * (eta30 + eta12) * (eta21 + eta03);

    hu_raw(7) = (3*eta21 - eta03) * (eta30 + eta12) * ...
                ((eta30 + eta12)^2 - 3*(eta21 + eta03)^2) - ...
                (eta30 - 3*eta12) * (eta21 + eta03) * ...
                (3*(eta30 + eta12)^2 - (eta21 + eta03)^2);

    hu = -sign(hu_raw) .* log10(abs(hu_raw) + eps);
end

function T = tablo_olustur(nesne_adlari, props, ar, circ, hu)
% Hesaplanan özellikleri daha düzenli görmek için MATLAB tablosuna aktarıyorum.

    N = length(props);

    No = (1:N)';
    Nesne = cell(N, 1);

    for i = 1:N
        if i <= length(nesne_adlari)
            Nesne{i} = nesne_adlari{i};
        else
            Nesne{i} = sprintf('Nesne-%d', i);
        end
    end

    Cx = zeros(N,1);
    Cy = zeros(N,1);
    Alan = zeros(N,1);
    Perimeter = zeros(N,1);
    MajorAxis = zeros(N,1);
    MinorAxis = zeros(N,1);
    Orientation = zeros(N,1);

    for i = 1:N
        Cx(i) = props(i).Centroid(1);
        Cy(i) = props(i).Centroid(2);
        Alan(i) = props(i).Area;
        Perimeter(i) = props(i).Perimeter;
        MajorAxis(i) = props(i).MajorAxisLength;
        MinorAxis(i) = props(i).MinorAxisLength;
        Orientation(i) = props(i).Orientation;
    end

    T = table( ...
        No, ...
        Nesne, ...
        Cx, ...
        Cy, ...
        Alan, ...
        Perimeter, ...
        MajorAxis, ...
        MinorAxis, ...
        Orientation, ...
        ar, ...
        circ, ...
        hu(:,1), ...
        hu(:,2), ...
        hu(:,3), ...
        hu(:,4), ...
        hu(:,5), ...
        hu(:,6), ...
        hu(:,7), ...
        'VariableNames', { ...
            'No', ...
            'Nesne', ...
            'Cx', ...
            'Cy', ...
            'Alan', ...
            'Perimeter', ...
            'MajorAxis', ...
            'MinorAxis', ...
            'Orientation', ...
            'AspectRatio', ...
            'Circularity', ...
            'Hu1', ...
            'Hu2', ...
            'Hu3', ...
            'Hu4', ...
            'Hu5', ...
            'Hu6', ...
            'Hu7' ...
        } ...
    );
end

function feat_norm = ozellik_vektoru_olustur(ar, circ, hu)
% SSD hesabında kullanılacak özellik vektörünü oluşturup normalize ediyorum.
%
% Karşılaştırmada kullandığım özellikler:
%   aspect ratio
%   circularity
%   Hu1-Hu7

    feat = [ar(:), circ(:), hu];

    feat(~isfinite(feat)) = 0;

    mu = mean(feat, 1);
    sigma = std(feat, 0, 1);

    sigma(sigma == 0) = 1;

    feat_norm = (feat - mu) ./ sigma;
end