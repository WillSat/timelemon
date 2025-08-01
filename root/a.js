const test_server = 'https://timelemon.qzz.io/';

const timeline = document.getElementById('timeline');
const tooltip = document.getElementById('tooltip');
const blurbox = document.getElementById('blurbox');
let ifMoveWhileClick = false;
blurbox.addEventListener('pointerdown', () => {
    const up = () => {
        blurbox.removeEventListener('pointermove', move);
        blurbox.removeEventListener('pointerup', up);
        blurbox.style.display = 'none';
    }

    const move = () => {
        blurbox.removeEventListener('pointermove', move);
        blurbox.removeEventListener('pointerup', up);
        ifMoveWhileClick = true;
    }

    blurbox.addEventListener('pointerup', up);
    blurbox.addEventListener('pointermove', move);
});

// 颜色映射
const colors = {
    '政治': '#FFCCBC',
    '经济': '#FFE0B2',
    '社会民生': '#F0F4C3',
    '公共安全': '#B2DFDB',
    '文化': '#BBDEFB',
    '科技': '#C5CAE9',
    '其他': '#CFD8DC',
    'important': '#00B0FF',
    'urgent': '#FF9100',
    'critical': '#FF3D00',
};

const priority = {
    'important': 1,
    'urgent': 2,
    'critical': 3,
    '政治': 1,
    '经济': 2,
    '社会民生': 3,
    '公共安全': 4,
    '文化': 5,
    '科技': 6,
    '其他': 7,
};

// 渲染今天
randerDay(new Date());

function randerDay(date) {
    document.getElementById('currentDate').textContent =
        `${date.getFullYear()} 年 ${date.getMonth() + 1} 月 ${date.getDate()} 日`;

    const oneDayKeywords = { 1: [], 2: [], 3: [], 4: [] };

    const dateCode = date.getFullYear()
        + ('0' + (date.getMonth() + 1)).slice(-2)
        + ('0' + date.getDate()).slice(-2);

    for (const quarterDayNum of [1, 2, 3, 4]) {
        try {
            fetch(`${test_server}/${dateCode}-${quarterDayNum}.json`)
                .then(r => r.json())
                .then(quarterDayWordsList => {
                    oneDayKeywords[quarterDayNum] = quarterDayWordsList.sort((a, b) => {
                        if (priority[a.sign] < priority[b.sign]) return true;
                        if (priority[a.sign] > priority[b.sign]) return false;
                        if (priority[a.sign] = priority[b.sign]) return priority[a.kind] > priority[b.kind];
                    });
                })
                .catch(() => {
                    console.log(`File ${dateCode}-${quarterDayNum}.json doesn't exist!`);
                })
                .finally(() => {
                    randerQuarterDay(quarterDayNum);
                });
        } catch (error) {
            // rander
            randerQuarterDay(quarterDayNum);
        }
    }

    // 渲染 1/4 时间线
    function randerQuarterDay(quarterDayNum) {
        const hourBlock = document.getElementById(`quarterday${quarterDayNum}`);
        // clean
        hourBlock.querySelectorAll('.keyword-item').forEach(e => e.remove());

        oneDayKeywords[quarterDayNum].forEach(keyword => {
            const keywordItem = document.createElement('div');
            keywordItem.className = 'keyword-item';
            keywordItem.textContent = keyword.word;
            keywordItem.style.backgroundColor = colors[keyword.kind];

            // 根据重要性设置文字颜色
            if (keyword.sign === 'critical') {
                keywordItem.style.fontWeight = 'bold';
            }

            keywordItem.style.borderLeft = `6px solid ${colors[keyword.sign]}`;

            // 鼠标事件
            keywordItem.addEventListener('pointermove', (e) => {
                tooltip.style.display = 'block';
                tooltip.style.left = `${e.pageX + 10}px`;
                tooltip.style.top = `${e.pageY + 10}px`;
                tooltip.innerHTML = `<strong>${keyword.word}</strong><br>${keyword.desc}<br><em>${keyword.sign === 'critical' ? '关键' : keyword.sign === 'urgent' ? '紧急' : '重要'} · ${keyword.kind}</em>`;
            });

            keywordItem.addEventListener('pointerleave', () => {
                tooltip.style.display = 'none';
            });

            keywordItem.addEventListener('click', () => {
                blurbox.style.display = 'flex';
                blurbox.innerHTML = `<strong>${keyword.word}</strong><br>${keyword.desc}<br><em>${keyword.sign === 'critical' ? '关键' : keyword.sign === 'urgent' ? '紧急' : '重要'} · ${keyword.kind}</em>`;
            });

            hourBlock.appendChild(keywordItem);
        });

        // 如果没有关键词，显示提示
        if (oneDayKeywords[quarterDayNum].length === 0) {
            const emptyMsg = document.createElement('div');
            emptyMsg.className = 'keyword-item empty';
            emptyMsg.textContent = 'Nothing happened?';
            emptyMsg.style.color = '#999';
            emptyMsg.style.fontStyle = 'italic';
            hourBlock.appendChild(emptyMsg);
        }
    }
}


{
    let dayOffset = 0;
    const oneDaysTime = 86400000;

    document.getElementById('preday').addEventListener('click', () => {
        dayOffset--;
        randerDay(new Date(Date.now() + dayOffset * oneDaysTime));
    });

    document.getElementById('nextday').addEventListener('click', () => {
        dayOffset++;
        randerDay(new Date(Date.now() + dayOffset * oneDaysTime));
    });
}