// nodes = [{ 
//     id: <String>, 
//     name: <Optional,String>, 
//     size: <Number>, 
//     backgroundColor: <String>, 
//     color: <String>, 
//     links: [<Other.id>] 
// }];

// Physics parameters
const params = {
    repulsion: 10000,
    linkDistance: 80,
    linkStrength: 0.2,
    friction: 0.35,
    gravity: 0,
    centerStrength: 0.04,
    dragStrength: 0.1
};

window.randerGraph = (graphContainer, nodes) => {
    // Initialize positions
    {
        const centerX = graphContainer.clientWidth / 2;
        const centerY = graphContainer.clientHeight / 2;

        nodes.forEach(node => {
            node.x = centerX + (Math.random() - 0.5) * graphContainer.clientWidth * 0.8;
            node.y = centerY + (Math.random() - 0.5) * graphContainer.clientHeight * 0.8;
            node.vx = 0;
            node.vy = 0;
        });
    }

    // Create DOM elements for nodes and links
    const nodeElements = {};
    const linkElements = [];

    function createGraph() {
        // Clear existing elements
        graphContainer.innerHTML = '';
        linkElements.length = 0;

        // Create links first (so they appear behind nodes)
        nodes.forEach(sourceNode => {
            if (sourceNode.links) {
                sourceNode.links.forEach(targetId => {
                    const targetNode = nodes.find(n => n.id === targetId);
                    if (targetNode) {
                        const link = document.createElement('div');
                        link.className = 'link';
                        graphContainer.appendChild(link);
                        linkElements.push({
                            element: link,
                            source: sourceNode,
                            target: targetNode
                        });
                    }
                });
            }
        });

        // Create nodes
        nodes.forEach(node => {
            const nodeElement = document.createElement('div');
            nodeElement.className = 'node';
            nodeElement.textContent = node.name ?? node.id;
            nodeElement.nid = node.id;
            nodeElement.style.width = `${node.size}px`;
            nodeElement.style.height = `${node.size}px`;
            nodeElement.style.color = node.color;
            nodeElement.style.backgroundColor = node.backgroundColor;
            nodeElement.style.left = `${node.x - node.size / 2}px`;
            nodeElement.style.top = `${node.y - node.size / 2}px`;
            nodeElement.style.fontSize = `${Math.max(8, node.size / 5)}px`;
            graphContainer.appendChild(nodeElement);

            nodeElements[node.id] = nodeElement;

            // Add event listeners
            nodeElement.addEventListener('mousedown', startDrag);
        });

        // Update link positions
        updateLinks();
    }

    // Update link positions based on node positions
    function updateLinks() {
        linkElements.forEach(link => {
            const dx = link.target.x - link.source.x;
            const dy = link.target.y - link.source.y;
            const length = Math.sqrt(dx * dx + dy * dy);

            link.element.style.width = `${length}px`;
            link.element.style.left = `${link.source.x}px`;
            link.element.style.top = `${link.source.y}px`;
            link.element.style.transform = `rotate(${Math.atan2(dy, dx)}rad)`;
        });
    }

    // Physics simulation
    function simulate() {
        // Apply repulsion between all nodes
        for (let i = 0; i < nodes.length; i++) {
            for (let j = i + 1; j < nodes.length; j++) {
                const node1 = nodes[i];
                const node2 = nodes[j];

                const dx = node2.x - node1.x;
                const dy = node2.y - node1.y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance > 0) {
                    const force = params.repulsion / (distance * distance * 0.5);
                    const fx = force * dx / distance;
                    const fy = force * dy / distance;

                    if (!node1.fixed) {
                        node1.vx -= fx;
                        node1.vy -= fy;
                    }
                    if (!node2.fixed) {
                        node2.vx += fx;
                        node2.vy += fy;
                    }
                }
            }
        }

        // Apply attraction for linked nodes
        nodes.forEach(node => {
            if (node.links) {
                node.links.forEach(linkId => {
                    const targetNode = nodes.find(n => n.id === linkId);
                    if (targetNode) {
                        const dx = targetNode.x - node.x;
                        const dy = targetNode.y - node.y;
                        const distance = Math.sqrt(dx * dx + dy * dy);

                        if (distance > 0) {
                            const force = (distance - params.linkDistance) * params.linkStrength;
                            const fx = force * dx / distance;
                            const fy = force * dy / distance;

                            if (!node.fixed) {
                                node.vx += fx;
                                node.vy += fy;
                            }
                            if (!targetNode.fixed) {
                                targetNode.vx -= fx;
                                targetNode.vy -= fy;
                            }
                        }
                    }
                });
            }
        });

        // Apply forces to nodes
        const centerX = graphContainer.clientWidth / 2;
        const centerY = graphContainer.clientHeight / 2;

        nodes.forEach(node => {
            if (node.fixed) {
                // 对于被拖拽的节点，应用弹性力回到鼠标位置
                const dx = node.targetX - node.x;
                const dy = node.targetY - node.y;
                node.vx += dx * params.dragStrength;
                node.vy += dy * params.dragStrength;
            } else {
                // Pull toward center
                const dx = centerX - node.x;
                const dy = centerY - node.y;
                node.vx += dx * params.centerStrength;
                node.vy += dy * params.centerStrength;

                // Apply gravity
                node.vy += params.gravity;
            }

            // Apply velocity with friction
            node.vx *= params.friction;
            node.vy *= params.friction;
            node.x += node.vx;
            node.y += node.vy;

            // Boundary checks
            const padding = 50;
            if (node.x < padding) node.vx += padding - node.x;
            if (node.x > graphContainer.clientWidth - padding) node.vx += graphContainer.clientWidth - padding - node.x;
            if (node.y < padding) node.vy += padding - node.y;
            if (node.y > graphContainer.clientHeight - padding) node.vy += graphContainer.clientHeight - padding - node.y;

            // Update DOM position
            if (nodeElements[node.id]) {
                nodeElements[node.id].style.left = `${node.x - node.size / 2}px`;
                nodeElements[node.id].style.top = `${node.y - node.size / 2}px`;
            }
        });

        // Update links
        updateLinks();
    }

    // Animation loop
    function animate() {
        simulate();
        requestAnimationFrame(animate);
    }

    // Interaction
    let draggedNode = null;
    let isDragging = false;
    let offsetX, offsetY;

    function startDrag(e) {
        e.preventDefault();
        e.stopPropagation();

        draggedNode = nodes.find(node => node.id === e.target.nid);
        if (draggedNode) {
            isDragging = true;

            const containerRect = graphContainer.getBoundingClientRect();
            offsetX = e.clientX - containerRect.left - draggedNode.x;
            offsetY = e.clientY - containerRect.top - draggedNode.y;

            // 设置拖拽状态
            draggedNode.fixed = true;
            draggedNode.targetX = draggedNode.x;
            draggedNode.targetY = draggedNode.y;

            // 视觉反馈
            e.target.classList.add('dragging');

            document.addEventListener('mousemove', dragNode);
            document.addEventListener('mouseup', stopDrag);
        }
    }

    function dragNode(e) {
        if (isDragging && draggedNode) {
            const containerRect = graphContainer.getBoundingClientRect();
            draggedNode.targetX = e.clientX - containerRect.left - offsetX;
            draggedNode.targetY = e.clientY - containerRect.top - offsetY;
        }
    }

    function stopDrag() {
        if (draggedNode) {
            draggedNode.fixed = false;
            delete draggedNode.targetX;
            delete draggedNode.targetY;
            nodeElements[draggedNode.id].classList.remove('dragging');
        }
        isDragging = false;
        draggedNode = null;
        document.removeEventListener('mousemove', dragNode);
        document.removeEventListener('mouseup', stopDrag);
    }

    // Handle window resize
    window.addEventListener('resize', () => {
        // Adjust nodes that might be outside new boundaries
        nodes.forEach(node => {
            if (node.x < 0) node.x = 0;
            if (node.x > graphContainer.clientWidth) node.x = graphContainer.clientWidth;
            if (node.y < 0) node.y = 0;
            if (node.y > graphContainer.clientHeight) node.y = graphContainer.clientHeight;
        });
    });

    // Initialize and start animation
    createGraph();
    animate();
}