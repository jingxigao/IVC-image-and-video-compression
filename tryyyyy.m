load mydata
figure('name', 'Rate vs Distortion')

plot(b_rate(1), PSNR(1), 'oy')
hold on
plot(b_rate(2), PSNR(2), 'ob')
% plot(b_rate(3), PSNR(3), '*b')
% plot(b_rate(4), PSNR(4), '*b')
% plot(b_rate(5), PSNR(5), 'or')
% plot(b_rate(6), PSNR(6), '*r')

hold on
xlim([0,40])
ylim([10, 50])

% legend('1','2','3','4' )
