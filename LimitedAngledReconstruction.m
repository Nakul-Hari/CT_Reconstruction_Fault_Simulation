phantom_size = 128;
I = phantom(phantom_size,phantom_size);
I = double(I);
I1 = zeros(256,256);
I1(64+(1:128),64 +(1:128)) = I;
 

N = size(I, 1);

Xc = phantom_size / 2;
Yc = phantom_size / 2;

R = zeros(2 * phantom_size, numAngles); % Radon transform using revolving ray

[Row_size, Column_Size] = size(R);

Downstream_Data = zeros(Row_size, Column_Size);
Downstream_Image = zeros(256, 256);
Buffer_Data = zeros(256, 256);

t = linspace(-128, +128, 257);


Filter = [t(129:256), abs(t(2:129))];

% Define filter parameters
N = 256; % Filter length

% Create Hamming window
w1 = zeros(1, N);
for n = 0:N-1
    w1(n+1) = 0.54 - 0.46 * cos(2 * pi * n / (N-1));
end

numZerosFront = floor((256 - length(w1)) / 2);
numZerosBack = 256 - length(w1) - numZerosFront;

% Append zeros to the front and back of the array
w = [zeros(1, numZerosFront), w1(129:256), w1(2:129), zeros(1, numZerosBack)];

% Apply window to the ideal low-pass filter
h = w .* Filter;


h = h / max(h);

plot(axie, h);
xlabel('w');
ylabel('Magnitude');
title('Applied Filter');

numAngles = 180; % the 

for t = 1:numAngles
    angle = deg2rad(-t); % Negative due to MATLAB's coordinate system

    for rho = 1:2*phantom_size
        ray = 1:2*phantom_size;

        % Calculate rotated coordinates
        x_rotated = (rho - phantom_size) * cos(angle) - (ray - phantom_size) * sin(angle) + Xc;
        y_rotated = (rho - phantom_size) * sin(angle) + (ray - phantom_size) * cos(angle) + Yc;

        % Interpolate using interp2
        intensity = interp2(I, x_rotated, y_rotated, 'linear', 0);

        R(rho, t) = sum(intensity); % Assign intensity to R
    end
    
    filtered_intensity = ifft(fft(R(:, t)).*(h(:)));

    % Accumulate the projection data onto the image
    Downstream_Image = Downstream_Image + imrotate(repmat(filtered_intensity, 1, 256), t + 90, 'crop');

    if (mod(t,1) == 0)
        % Display the reconstructed image for each angle
        imagesc(real(Downstream_Image(128+(-63:64), 128+(-63:64))));
        axis image;
        colormap('gray'); % Set the colormap to grayscale
        title(['Reconstructed Image for ', num2str(t) , ' angles']);
        colorbar; % Add a colorbar for intensity scale
        drawnow; % Update the figure
        %saveas(gcf, ['Reconstructedimage' , num2str(t) ,'.png']); 
        %pause(0.1)
    end

end


imagesc(I);
axis image;
colormap(gca, 'gray');
title('Original Image');
colorbar; % Add a colorbar for intensity scale