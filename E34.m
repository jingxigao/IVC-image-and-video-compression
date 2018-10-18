clear all;
path(path,'encoder')            % make the encoder-functions visible to matlab
path(path,'decoder')            % make the decoder-functions visible to matlab
path(path,'analysis')           % make the analysis-functions visible to matlab
input_image_filename1 = 'data\images\lena_small.tif';
input_image_filename2 = 'data\images\lena.tif';
ORIGINAL_image = double(imread( input_image_filename1 ));
ORIGINAL_image_1 = double(imread( input_image_filename2 ));
M = 8;
dif = inf;
MSE = inf;
for i = 0:255
    ind(i+1) = UniQuant(i/255,M);
    reps0(i+1) = 255*InvUniQuant(ind(i+1),M);
end
            
for i = 1:length(reps0)
    reps_vq(:,:,i) = repmat(reps0(i),2,2);
end

%% HERE FIND THE RIGHT REPRESENTATIVES FOR QUANTIZATION
while(dif > 0.1)
    Bq = zeros(1,size(reps_vq,3));  %this contains no of blocks in same bin
    total = zeros(size(reps_vq)); %this contains sums of blocks in same bin
    total_error = 0; %total squared error
    new_vals = zeros(2,2,length(ORIGINAL_image(:))/4); %this contains the quantized blocks
    iteration = 0;
    for k = 1:3
        for i = 1:2:size(ORIGINAL_image,1)
            for j = 1:2:size(ORIGINAL_image,2)
                iteration = iteration + 1;
                block = ORIGINAL_image(i:i+1, j:j+1, k);
                [r, SE, index] = closest_VQ(block, reps_vq);
                new_vals(:,:,iteration)= r;
                total(:,:,index) = total(:,:,index)+block;
                total_error = total_error + SE;
                Bq(index)= Bq(index)+1;
            end
        end
    end

    MSE_new = total_error/length(ORIGINAL_image(:));
    dif = MSE-MSE_new;
    MSE = MSE_new;

    %get rid of 0 entries - representatives that are not used
    ind_zero = find(Bq==0);
    ind_nonzero = find(Bq~=0);

    %update representatives
    for i = 1:length(ind_nonzero)
        reps_vq(:,:, ind_nonzero(i)) = total(:,:,ind_nonzero(i))/Bq(ind_nonzero(i));
    end

    if(length(ind_zero) > 0) %if found non used representatives 
        [~, sorted_indices] = sort(Bq,'descend');
        top_ind = sorted_indices(1:length(ind_zero)); %indices for which representatives occur the most
        bottom_ind = sorted_indices(end-length(ind_zero)+1:end); %indices for which representatives never occur
        
        vec=zeros(2,2,length(bottom_ind));
        % add a 1 to the 4th number, just to make some difference from the
        % oringinal nonzero vector
        vec(2,2,:)=1;
        reps_vq(:,:,bottom_ind) = reps_vq(:,:, top_ind) + vec;
    end
end


%% Use the already calculated representative to quantilize the original image
Quantized_image = zeros(size(ORIGINAL_image_1));
it = 0;
indices = [];
Bq = zeros(1,size(reps_vq,3));
for k = 1:3
    for i = 1:2:size(ORIGINAL_image_1,1)
        for j = 1:2:size(ORIGINAL_image_1,2)
            it = it + 1;
            block = ORIGINAL_image_1(i:i+1, j:j+1, k);
            [r, SE, index] = closest_VQ(block, reps_vq);
            indices = [indices;index];
            new_vals(:,:,it)= r;
            Quantized_image(i:i+1, j:j+1,k) = r;
            Bq(index)= Bq(index)+1;
        end
    end
end
 
PSNR = calcPSNR( 3,ORIGINAL_image_1, Quantized_image);

figure(1)
imagesc(ORIGINAL_image_1/255)
title('ORIGINAL_image');

figure(2)
imagesc(Quantized_image/255)
title('Quantized_image');


PMF = Bq/sum(Bq);
[ BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( PMF );

data =indices;
bytestream = enc_huffman_new(data, BinCode, Codelengths);
dec_data = dec_huffman (bytestream, BinaryTree, max(size(data)));
br = length(bytestream)*8/(size(ORIGINAL_image_1,1)*size(ORIGINAL_image_1,2));

count = 0;
for k = 1:3
    for i= 1:2:size(ORIGINAL_image_1,1)
        for j = 1:2:size(ORIGINAL_image_1,2)
            count = count+1;
            block = reps_vq(:,:,dec_data(count));
            RECONSTRUCTED_image(i:i+1, j:j+1, k) = block;
        end
    end
end

figure(3)
imagesc(RECONSTRUCTED_image/255)
title('RECONSTRUCTED_image');

